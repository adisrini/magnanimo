const { Logging } = require("@google-cloud/logging");

export function logError(err: any, context = {}) {
  // This is the name of the StackDriver log stream that will receive the log
  const logging = new Logging();
  const log = logging.log("errors");

  // https://cloud.google.com/logging/docs/api/ref_v2beta1/rest/v2beta1/MonitoredResource
  const metadata = {
    resource: {
      type: "cloud_function",
      labels: { function_name: process.env.FUNCTION_NAME }
    }
  };

  // https://cloud.google.com/error-reporting/reference/rest/v1beta1/ErrorEvent
  const errorEvent = {
    message: err.stack,
    serviceContext: {
      service: process.env.FUNCTION_NAME,
      resourceType: "cloud_function"
    },
    context: context
  };

  // Write to the log. The log.write() call returns a Promise if you want to
  // make sure that the log was written successfully.
  const entry = log.entry(metadata, errorEvent);
  return log.write(entry);
}

export function userFacingMessage(error: any) {
  return error.type
    ? error.message
    : "An error occurred, developers have been alerted";
}
