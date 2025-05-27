const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const item = JSON.parse(event.body);
  const params = {
    TableName: "courses",
    Item: item
  };
  await db.put(params).promise();
  return { statusCode: 200, body: JSON.stringify({ message: "Course saved" }) };
};
