const AWS = require("aws-sdk");
const db = new AWS.DynamoDB.DocumentClient();
const cloudwatch = new AWS.CloudWatch();

exports.handler = async () => {
  const params = { TableName: "authors" };

  try {
    const result = await db.scan(params).promise();

    // 📊 Кастомна метрика
    await cloudwatch.putMetricData({
      Namespace: "Custom/LabMetrics",
      MetricData: [
        {
          MetricName: "GetAllAuthorsInvoked",
          Dimensions: [
            {
              Name: "Function",
              Value: "get-all-authors"
            }
          ],
          Unit: "Count",
          Value: 1
        }
      ]
    }).promise();

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT,DELETE"
      },
      isBase64Encoded: false,
      body: JSON.stringify(result.Items)
    };
  } catch (err) {
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT,DELETE"
      },
      isBase64Encoded: false,
      body: JSON.stringify({ error: err.message })
    };
  }
};
