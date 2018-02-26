import swiftclient

#making connection
user = 'reguser'
passw = 'linux'
authurl = 'http://controller:5000/v3'
conn = swiftclient.Connection(authurl,user,passw,auth_version=3,tenant_name='reguser')

#list avail containers
resp_headers, containers = conn.get_account()
print("Response headers: %s" % resp_headers)
for container in containers:
    print(container)

#creating a new container
container_name = 'c1'
conn.put_container(container_name)

#list objets in container
container_name='c1'
resp_headers, containers = conn.get_container(container_name)
print("Response headers: %s" % resp_headers)
for container in containers:
    print(container)

#delete a container
container_name='c1'
conn.delete_container(container_name)

#craeate new object with content of loacalfile
container_name = 'c1'
file_name = 'f1'
with open('local.txt', 'r') as local:
    conn.put_object(
        container_name,
        file_name,
        contents=local,
        content_type='text/plain'
    )

#delete object in container
obj_name = 'object1'
container_nme = 'c1'
try:
    conn.delete_object(container_name, obj_name)
    print("Successfully deleted the object")
except ClientException as e:
    print("Failed to delete the object with error: %s" % e)



