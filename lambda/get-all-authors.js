const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async () => {
  const params = { TableName: "authors" };
  const result = await db.scan(params).promise();
  return { statusCode: 200, body: JSON.stringify(result.Items) };
};
