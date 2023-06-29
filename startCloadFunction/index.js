const project = '<MYPROJECTID>';
const zone = '<ZONE>'
const instance = 'my-mc-server'


const functions = require('@google-cloud/functions-framework');
const {InstancesClient} = require('@google-cloud/compute')
const computeClient = new InstancesClient();

//start async function via http/s request
functions.http('startInstancehttp', (req, res) => {

    res.send(startserver());
});

async function startserver(){
   const request = {
      instance,
      project,
      zone,
    };

    //start VM
    const response = await computeClient.start(request);
    return response;
}