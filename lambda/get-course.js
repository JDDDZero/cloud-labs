const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const id = event.pathParameters.id;
  const params = {
    TableName: "courses",
    Key: { id }
  };
  const result = await db.get(params).promise();
  return { statusCode: 200, body: JSON.stringify(result.Item) };
};
