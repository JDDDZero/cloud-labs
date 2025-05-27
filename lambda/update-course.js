const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const item = JSON.parse(event.body);
  const params = {
    TableName: "courses",
    Key: { id: item.id },
    UpdateExpression: "set #name = :name",
    ExpressionAttributeNames: { "#name": "name" },
    ExpressionAttributeValues: { ":name": item.name }
  };
  await db.update(params).promise();
  return { statusCode: 200, body: JSON.stringify({ message: "Course updated" }) };
};
