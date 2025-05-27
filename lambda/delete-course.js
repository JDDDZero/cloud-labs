const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const id = event.pathParameters.id;
  const params = {
    TableName: "courses",
    Key: { id }
  };
  await db.delete(params).promise();
  return { statusCode: 200, body: JSON.stringify({ message: "Course deleted" }) };
};
