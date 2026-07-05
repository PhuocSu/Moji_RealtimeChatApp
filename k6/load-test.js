import http from 'k6/http';
import { check, sleep } from 'k6';

// Cấu hình load test
export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Tăng dần lên 10 users trong 30s
    { duration: '1m',  target: 10 },  // Giữ 10 users trong 1 phút
    { duration: '30s', target: 0  },  // Giảm về 0
  ],
  thresholds: {
    // Pipeline fail nếu không đạt ngưỡng này
    http_req_duration: ['p(95)<500'],  // 95% request phải < 500ms
    http_req_failed:   ['rate<0.01'],  // Tỉ lệ lỗi < 1%
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:5173';

export default function () {
  // Test trang chủ
  const res = http.get(`${BASE_URL}`);
  check(res, {
    'homepage status 200': (r) => r.status === 200,
    'homepage < 500ms':    (r) => r.timings.duration < 500,
  });

  sleep(1);
}
