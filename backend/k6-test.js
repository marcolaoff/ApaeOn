import http from 'k6/http';
import { sleep, check } from 'k6';

// This is the options object for k6.
// It defines the load test parameters.
// For more options, see: https://k6.io/docs/using-k6/k6-options/
export const options = {
  // Simulate 10 virtual users.
  vus: 10,
  // For a duration of 30 seconds.
  duration: '30s',
};

// This is the main function that will be executed by each virtual user.
export default function () {
  // The URL of the endpoint to test.
  // Assumes the backend is running on localhost:3000.
  const url = 'http://localhost:3000/pix';

  // The payload for the POST request.
  // We use dynamic data to simulate different users.
  const payload = JSON.stringify({
    amount: 10, // You can randomize this value if needed
    email: `user+${__VU}@example.com`, // Unique email for each virtual user
    fullName: `User ${__VU}`, // Unique name for each virtual user
  });

  // The headers for the request.
  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  // Make the POST request.
  const res = http.post(url, payload, params);

  // Check if the request was successful.
  // A status of 200 means OK.
  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  // Wait for 1 second before the next iteration.
  // This is to simulate a user waiting between actions.
  sleep(1);
}
