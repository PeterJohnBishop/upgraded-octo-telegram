// Middleware to log request headers, body, and method

const apiLogging = (req, res, next) => {
    console.log(`Timestamp: [${new Date().toISOString()}]`);
    console.log('Headers: ', JSON.stringify(req.headers, null, 2));
    console.log(`Request: ${req.method} ${req.url}`);
    console.log('Body: ', JSON.stringify(req.body, null, 2));
    next();
};

export default apiLogging;
