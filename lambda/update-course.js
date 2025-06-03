const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const item = JSON.parse(event.body);

  const updateExpressions = [];
  const expressionAttributeNames = {};
  const expressionAttributeValues = {};

  if (item.title) {
    updateExpressions.push("#title = :title");
    expressionAttributeNames["#title"] = "title";
    expressionAttributeValues[":title"] = item.title;
  }

  if (item.authorId) {
    updateExpressions.push("#authorId = :authorId");
    expressionAttributeNames["#authorId"] = "authorId";
    expressionAttributeValues[":authorId"] = item.authorId;
  }

  if (updateExpressions.length === 0) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "No fields to update" })
    };я
  }

  const params = {
    TableName: "courses",
    Key: { id: item.id },
    UpdateExpression: "set " + updateExpressions.join(", "),
    ExpressionAttributeNames: expressionAttributeNames,
    ExpressionAttributeValues: expressionAttributeValues
  };

  await db.update(params).promise();

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Course updated" })
  };
};
