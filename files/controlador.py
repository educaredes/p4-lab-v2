from p4utils.utils.sswitch_p4runtime_API import SimpleSwitchP4RuntimeAPI


# The constructor checks if there is a P4 program in the switch. If 
# there is one, it does not do anything else. If there is not, it 
# pushes the p4 program in the switch. In any case, the methods in
# controller allows to control the switch (e.g., modifying tables) 
#Switch A
controller = SimpleSwitchP4RuntimeAPI(device_id=1, grpc_port=9559,
                                      p4rt_path='basico_p4rt.txt',
                                      json_path='basico.json')

# If we want to force the modification of a P4 program already in the
# switch, we need to execute (it uploads the p4 program indicated when
# the object 'controller' was created):
# controller.reset_state()

# To empty the tables in the switch (if needed). 
#controller.table_clear('ipv4_lpm')

#Adding entries to the switch tables
controller.table_set_default('ipv4_lpm','drop')
controller.table_add('ipv4_lpm', 'ipv4_forward',['10.0.0.2/32'], ['00:00:00:00:00:01','1'])
controller.table_add('ipv4_lpm', 'ipv4_forward',['10.0.1.0/24'], ['00:00:00:00:02:02','2'])
controller.table_add('ipv4_lpm', 'ipv4_forward',['10.0.2.0/24'], ['00:00:00:00:03:02','3'])



# Switch B
controller = SimpleSwitchP4RuntimeAPI(device_id=2, grpc_port=9560,
                                      p4rt_path='basico_p4rt.txt',
                                      json_path='basico.json')


#controller.table_clear('ipv4_lpm')
controller.table_set_default('ipv4_lpm','drop')
controller.table_add('ipv4_lpm', 'ipv4_forward',['10.0.0.0/24'], ['00:00:00:00:01:02','2'])
controller.table_add('ipv4_lpm', 'ipv4_forward',['10.0.1.2/32'], ['00:00:00:00:00:02','1'])
controller.table_add('ipv4_lpm', 'ipv4_forward',['10.0.2.0/24'], ['00:00:00:00:03:03','3'])



# Swicth C
controller = SimpleSwitchP4RuntimeAPI(device_id=3, grpc_port=9561,
                                      p4rt_path='basico_p4rt.txt',
                                      json_path='basico.json')


#controller.table_clear('ipv4_lpm')
controller.table_set_default('ipv4_lpm','drop')
controller.table_add('ipv4_lpm', 'ipv4_forward',['10.0.0.0/24'], ['00:00:00:00:01:03','2'])
controller.table_add('ipv4_lpm', 'ipv4_forward',['10.0.1.0/24'], ['00:00:00:00:02:03','3'])
controller.table_add('ipv4_lpm', 'ipv4_forward',['10.0.2.2/32'], ['00:00:00:00:00:03','1'])

