curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"installInHw":"true", "name":"TEST_IN", "node": {"id":"33:33:33:33:33:33:33:01", "type":"OF"}, "ingressPort": "3", "priority":"65535","actions":["OUTPUT=5"]}' http://$1:8080/controller/nb/v2/flowprogrammer/default/node/OF/33:33:33:33:33:33:33:01/staticFlow/TEST_IN
curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"installInHw":"true", "name":"TEST_OUT", "node": {"id":"33:33:33:33:33:33:33:01", "type":"OF"}, "ingressPort": "5", "priority":"65535","actions":["OUTPUT=3"]}' http://$1:8080/controller/nb/v2/flowprogrammer/default/node/OF/33:33:33:33:33:33:33:01/staticFlow/TEST_OUT
curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"installInHw":"true", "name":"TEST_IN_MY", "node": {"id":"33:33:33:33:33:33:33:01", "type":"OF"}, "ingressPort": "4", "priority":"65535","actions":["OUTPUT=6"]}' http://$1:8080/controller/nb/v2/flowprogrammer/default/node/OF/33:33:33:33:33:33:33:01/staticFlow/TEST_IN_MY
curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"installInHw":"true", "name":"TEST_OUT_MY", "node": {"id":"33:33:33:33:33:33:33:01", "type":"OF"}, "ingressPort": "6", "priority":"65535","actions":["OUTPUT=4"]}' http://$1:8080/controller/nb/v2/flowprogrammer/default/node/OF/33:33:33:33:33:33:33:01/staticFlow/TEST_OUT_MY

curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"installInHw":"true", "name":"SANDBOX_IN", "node": {"id":"33:33:33:33:33:33:33:11", "type":"OF"}, "ingressPort": "2", "priority":"65535","actions":["OUTPUT=3"]}' http://$1:8080/controller/nb/v2/flowprogrammer/default/node/OF/33:33:33:33:33:33:33:11/staticFlow/SANDBOX_IN
curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"installInHw":"true", "name":"SANDBOX_OUT", "node": {"id":"33:33:33:33:33:33:33:11", "type":"OF"}, "ingressPort": "3", "priority":"65535","actions":["OUTPUT=2"]}' http://$1:8080/controller/nb/v2/flowprogrammer/default/node/OF/33:33:33:33:33:33:33:11/staticFlow/SANDBOX_OUT
curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"installInHw":"true", "name":"MY_IN", "node": {"id":"33:33:33:33:33:33:33:21", "type":"OF"}, "ingressPort": "2", "priority":"65535","actions":["OUTPUT=3"]}' http://$1:8080/controller/nb/v2/flowprogrammer/default/node/OF/33:33:33:33:33:33:33:21/staticFlow/MY_IN
curl -u admin:admin -H 'Content-type: application/json' -X PUT -d '{"installInHw":"true", "name":"MY_OUT", "node": {"id":"33:33:33:33:33:33:33:21", "type":"OF"}, "ingressPort": "3", "priority":"65535","actions":["OUTPUT=2"]}' http://$1:8080/controller/nb/v2/flowprogrammer/default/node/OF/33:33:33:33:33:33:33:21/staticFlow/MY_OUT

