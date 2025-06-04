const AWS = require("aws-sdk");
const db = new AWS.DynamoDB();

exports.handler = async () => {
  const params = { TableName: "courses" };

  try {
    const data = await db.scan(params).promise();

    const courses = (data.Items || []).map(item => ({
      id: item.id?.S || null,
      title: item.title?.S || null,
      watchHref: item.watchHref?.S || null,
      authorId: item.authorId?.S || null,
      length: item.length?.S || null,
      category: item.category?.S || null
    }));

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT,DELETE"
      },
      body: JSON.stringify(courses)
    };
  } catch (err) {
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT,DELETE"
      },
      body: JSON.stringify({ error: "Failed to fetch courses", details: err.message })
    };
  }
};
