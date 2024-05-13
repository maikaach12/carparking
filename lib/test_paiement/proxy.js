const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

app.use('/api', createProxyMiddleware({
  target: 'https://pay.chargily.com/test/dashboard/',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '',
  },
}));

app.listen(3000, () => {
  console.log('Proxy server listening on port 3000');
});