const projectId = '<MYPROJECTID> ';
const zone = 'australia-southeast1-a'
const instanceName = 'my-mc-server-1'

const functions = require('@google-cloud/functions-framework');
const compute = require('@google-cloud/compute');

//start async function via http/s request
functions.http('startInstancehttp', (req, res) => {

  const instancesClient = new compute.InstancesClient();

  const response = instancesClient.start({
    project: projectId,
    zone,
    instance: instanceName,
  });
  let operation = response.latestResponse;

  // check if operation is complete.
  if (operation.status == 'DONE') {
      console.log('Instance startted.');
  };

  res.end('ok');

  
});
