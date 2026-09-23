-- Definición del protocolo: protocolo_TeP4 es la variable que representa el protocolo, id_interno_protocolo es el identificador único del protocolo y Protocolo TeP4 es el nombre que aparece en Wireshark
local TeP4_protocol = Proto("TeP4", "TeP4 protocol")


-- Definición de los campos del protocolo según la especificación

-- Variable f_route que es un campo del protocolo de tipo entero sin signo de 8 bits
local f_route = ProtoField.uint8(
    "TeP4.route", -- El nombre interno del campo en Wireshark es TeP4.route
    "Route", -- El nombre que se muestra en Wireshark para este campo es Route
    base.DEC, -- El valor se muestra en formato decimal
    {
        [1] = "Clockwise (sA -> sC -> sB -> sA)", -- Si el valor de este campo es 1, Wireshark muestra "Sentido horario (sA -> sC -> sB -> sA)"
        [2] = "Anticlockwise (sA -> sB -> sC -> sA)" -- Si el valor de este campo es 2, Wireshark muestra "Sentido antihorario (sA -> sB -> sC -> sA)"
    }
)

-- Variable f_counter que es un campo del protocolo 
local f_counter = ProtoField.uint8(
    "TeP4.counter", -- El nombre interno del campo en Wireshark es TeP4.counter
    "Counter" -- El nombre que se muestra en Wireshark para este campo es Counter 
)

-- Variable f_reserved que es un campo del protocolo de tipo entero sin signo de 8 bits
local f_reserved = ProtoField.uint16(
    "TeP4.reserved", -- El nombre interno del campo en Wireshark es id_interno_protocolo.reserved
    "Reserved", -- El nombre que se muestra en Wireshark para este campo es "Reserved"
    base.DEC -- El valor se muestra en formato hexadecimal
)

-- Asignación de los campos al protocolo
TeP4_protocol.fields = { f_route, f_counter, f_reserved } -- Asigna al protocolo protocolo_TeP4 los siguientes campos que debe mostrar y analizar: f_route, f_reserved y f_ingress_switch_mac


-- Función principal del disector
function TeP4_protocol.dissector(buffer, pinfo, tree) -- Función que analiza cada paquete recibido para comprobar que la cabecera extra del protocolo está completa
    if buffer:len() < 4 then -- La cabecera del protocolo tiene que tener al menos 4 bytes
        pinfo.cols.protocol = "Header too short!" -- Si no ocurre lo anterior, se avisa en Wireshark
        return false
    end

    pinfo.cols.protocol = TeP4_protocol.name -- Establece el nombre del protocolo en la columna de Wireshark

    local subtree = tree:add(TeP4_protocol, buffer(0, 4), "TeP4 protocol header") -- tree:add añade una sección desplegable en el panel de detalles del paquete y dentro de esa sección desplegable se muestran los campos definidos antes como route, counter y reserved

    local offset = 0 -- Se inicializa la variable offset en 0, la cual lleva la cuenta de la posición actual dentro del buffer de datos del paquete

    -- Extrae el campo Route (1 byte)
    subtree:add_le(f_route, buffer(offset, 1)) -- Añade el campo f_route (Route) al subtree, leyendo 1 byte desde la posición actual (offset) del buffer
    offset = offset + 1 -- Avanza el offset 1 byte para situarse en el siguiente campo de la cabecera

    -- Extrae el campo counter (1 byte)
    subtree:add_le(f_counter, buffer(offset, 1)) -- Añade el campo f_counter (Reserved) al subtree, leyendo 1 byte desde la posición actual (offset) del buffer
    offset = offset + 1 -- Avanza el offset 1 byte para situarse en el siguiente campo de la cabecera

    -- Extrae el campo Reserved (2 bytes)
    subtree:add(f_reserved, buffer(offset, 2)) -- Añade el campo Reserved al panel de detalles de Wireshark
    offset = offset + 2 -- Avanza el offset 6 bytes para situarse en el siguiente campo de la cabecera


    -- Verifica que haya datos restantes antes de llamar al disector de IP
    if buffer:len() > offset then --Comprueba si quedan datos en el buffer después de leer la cabecera (es decir, si hay un paquete IP para analizar)
        local ip_offset = offset
        -- Calcula la longitud real de la cabecera IP usando el campo IHL (primer byte, 4 bits menos significativos)
        local ihl = buffer(ip_offset, 1):uint() % 0x10 -- Extrae el valor IHL
        local ip_header_length = ihl * 4 -- Longitud real de la cabecera IP en bytes
        if ip_header_length < 20 then ip_header_length = 20 end -- Por seguridad, mínimo 20 bytes
        -- ...existing code...
        Dissector.get("ip"):call(buffer(ip_offset):tvb("IP Packet"), pinfo, tree)
    end

    -- Devuelve true para indicar que el disector procesó el paquete
    return true
end

-- Registra el disector para el EtherType 0xA000
local ethertype_table = DissectorTable.get("ethertype")
ethertype_table:add(0x9005, TeP4_protocol)

-- Función para inicializar el disector
function init_listener()
    print("TeP4 dissector loadede") -- Imprime el mensaje "El disector del protocolo TeP4 se ha cargado correctamente" en la consola cuando el script se carga.
end

-- Llama a la función de inicialización
init_listener()
