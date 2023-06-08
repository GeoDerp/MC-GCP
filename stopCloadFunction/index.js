// this should not be required if autostop enabled on the container environment variables
const projectId = '<MYPROJECTID>';
const zone = '<REGION>-a'
const instanceName = 'my-mc-server-1'

const functions = require('@google-cloud/functions-framework');
const compute = require('@google-cloud/compute');

//start async function via http/s request
functions.http('stopInstancehttp', (req, res) => {

  const instancesClient = new compute.InstancesClient();

  const response = instancesClient.stop({
    project: projectId,
    zone,
    instance: instanceName,
  });
  let operation = response.latestResponse;

  // check if operation is complete.
  if (operation.status == 'DONE') {
      console.log('Instance stopped.');
  };

  res.end('OK');

  
});
