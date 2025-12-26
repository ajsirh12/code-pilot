---
name: profile
description: 애플리케이션 성능 프로파일링 분석 및 가이드
argument-hint: "[언어/프레임워크] [프로파일 파일 경로]"
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
---

# 프로파일링 명령어

애플리케이션의 CPU, 메모리 사용량을 프로파일링하고 분석한다.

## 실행 단계

1. **프로젝트 분석**
   - 언어/프레임워크 자동 감지
   - 기존 프로파일링 설정 확인
   - 프로파일 결과 파일 탐색

2. **프로파일링 도구 가이드**

   **Node.js:**
   ```bash
   # CPU 프로파일링
   node --prof app.js
   node --prof-process isolate-*.log > profile.txt

   # 내장 프로파일러
   node --inspect app.js
   # Chrome DevTools > Performance 탭
   ```

   **Python:**
   ```bash
   # cProfile
   python -m cProfile -o profile.pstats app.py
   python -m pstats profile.pstats

   # py-spy (프로덕션 안전)
   py-spy top --pid <PID>
   py-spy record -o profile.svg -- python app.py
   ```

   **Go:**
   ```go
   import _ "net/http/pprof"
   // http://localhost:6060/debug/pprof/
   ```
   ```bash
   go tool pprof http://localhost:6060/debug/pprof/profile
   ```

   **Java:**
   ```bash
   # async-profiler
   ./profiler.sh -d 30 -f profile.html <PID>

   # JFR
   jcmd <PID> JFR.start duration=60s filename=profile.jfr
   ```

3. **프로파일 결과 분석**
   - 핫스팟 함수 식별
   - 콜 스택 분석
   - 메모리 할당 패턴
   - GC 오버헤드

4. **출력 형식**
   ```
   ## 프로파일 분석 결과

   ### CPU 핫스팟 (Top 10)
   | 함수 | 시간(%) | 호출횟수 | 파일:라인 |

   ### 메모리 사용
   - 총 할당: X MB
   - GC 횟수: Y회
   - 주요 할당 지점: ...

   ### 최적화 권장사항
   1. [HIGH] processData() - 알고리즘 개선 필요
   2. [MEDIUM] parseJSON() - 캐싱 고려
   ```
