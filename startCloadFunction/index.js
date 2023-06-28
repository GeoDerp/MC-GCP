const project = '<MYPROJECTID>';
const zone = '<REGION>-a'
const instance = 'my-mc-server-1'

const functions = require('@google-cloud/functions-framework');
const {InstancesClient} = require('@google-cloud/compute')
const computeClient = new InstancesClient();

//start async function via http/s request
functions.http('startInstancehttp', (req, res) => {

   const request = {
      instance,
      project,
      zone,
    };

    //start VM
    const response = await computeClient.start(request);
    return(res);
});
