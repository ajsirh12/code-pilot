---
name: benchmark
description: 코드 벤치마크 작성 및 실행 가이드
argument-hint: "[대상 함수/모듈] [--compare]"
allowed-tools: ["Read", "Glob", "Grep", "Write", "Bash"]
---

# 벤치마크 명령어

특정 코드의 성능을 측정하고 비교하는 벤치마크를 작성/실행한다.

## 실행 단계

1. **벤치마크 대상 식별**
   - 사용자 지정 함수/모듈
   - 또는 코드베이스 내 성능 중요 함수 자동 탐지

2. **벤치마크 코드 생성**

   **Node.js (Vitest/Jest):**
   ```typescript
   import { bench, describe } from 'vitest';

   describe('Performance', () => {
     bench('processData', () => {
       processData(testInput);
     });

     bench('processData - optimized', () => {
       processDataOptimized(testInput);
     });
   });
   ```

   **Python (pytest-benchmark):**
   ```python
   import pytest

   def test_process_data(benchmark):
       result = benchmark(process_data, test_input)
       assert result is not None

   @pytest.mark.benchmark(group="comparison")
   def test_process_data_optimized(benchmark):
       benchmark(process_data_optimized, test_input)
   ```

   **Go:**
   ```go
   func BenchmarkProcessData(b *testing.B) {
       for i := 0; i < b.N; i++ {
           ProcessData(testInput)
       }
   }
   ```

3. **벤치마크 실행**
   ```bash
   # Node.js
   npx vitest bench

   # Python
   pytest --benchmark-only

   # Go
   go test -bench=. -benchmem
   ```

4. **결과 비교** (`--compare` 옵션)
   - 이전 결과와 비교
   - 다른 구현체 간 비교
   - 통계적 유의성 분석

5. **출력 형식**
   ```
   ## 벤치마크 결과

   ### 측정 결과
   | 함수 | ops/sec | 평균 | 중위값 | p99 |

   ### 비교 (--compare)
   | 함수 | 변화 | 신뢰구간 |
   | processData | -15% 🔴 | ±2.3% |
   | optimized | +45% 🟢 | ±1.8% |

   ### 분석
   - 메모리 할당: X allocations
   - 권장사항: ...
   ```
