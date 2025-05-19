// load-tests/smoke.js
// Arquivo de testes para o K6
// -----------------------------

import http from 'k6/http';
import { check, sleep } from 'k6';

// URL base da aplicação
const BASE_URL = __ENV.BASE_URL || 'http://localhost:36629';

export const options = {
  vus: 1,           // 1 usuário virtual
  duration: '30s',  // durante 30 segundos
  thresholds: {
    'http_req_failed': ['rate<0.01'],        // <1% de falhas
    'http_req_duration': ['p(95)<500'],      // 95% das requisições < 500ms
  },
  tags: {
    'test_type': 'smoke',
    'app': 'online-boutique'
  }
};

export default function () {
  // Página inicial do frontend
  let res = http.get(`${BASE_URL}/`);
  check(res, {
    'status 200': (r) => r.status === 200,
    'loadgenerator ok': (r) => r.body.indexOf('Online Boutique') !== -1,
  });
  sleep(1);
}

