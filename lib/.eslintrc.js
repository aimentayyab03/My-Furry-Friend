module.exports = {
  extends: ['eslint:recommended'],
  parserOptions: {
    ecmaVersion: 2018,
  },
  env: {
    node: true,
    es6: true,
  },
  rules: {
    'no-unused-vars': 'warn', // Change to 'off' to disable completely
  },
};