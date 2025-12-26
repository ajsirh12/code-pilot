---
name: detect-n1
description: 코드에서 N+1 쿼리 문제 탐지
argument-hint: "[파일경로 또는 디렉토리]"
allowed-tools: ["Read", "Glob", "Grep"]
---

# N+1 쿼리 탐지 명령어

코드베이스를 분석하여 N+1 쿼리 문제가 발생할 수 있는 패턴을 찾는다.

## 실행 단계

1. **코드 탐색**
   - ORM 사용 파일 찾기
   - Repository/Service 레이어 분석
   - API 핸들러/컨트롤러 검사

2. **N+1 패턴 탐지**

   **루프 내 쿼리:**
   ```typescript
   // BAD: N+1 문제
   for (const user of users) {
     const posts = await postRepo.find({ userId: user.id });
   }
   ```

   **Lazy Loading 문제:**
   ```typescript
   // BAD: 관계 접근 시 추가 쿼리
   users.forEach(user => console.log(user.posts));
   ```

   **누락된 Eager Loading:**
   ```typescript
   // BAD: relations 없이 조회 후 관계 접근
   const users = await userRepo.find();
   users[0].posts; // 추가 쿼리 발생
   ```

3. **분석 대상 ORM**
   - TypeORM: `find()`, `findOne()`, relations
   - Prisma: `findMany()`, `include`
   - Sequelize: `findAll()`, `include`
   - Drizzle: `query`, `with`

4. **해결책 제안**
   ```typescript
   // GOOD: Eager loading 사용
   const users = await userRepo.find({
     relations: ['posts']
   });

   // GOOD: Query builder로 JOIN
   const users = await userRepo
     .createQueryBuilder('user')
     .leftJoinAndSelect('user.posts', 'post')
     .getMany();
   ```

5. **출력 형식**
   ```
   ## N+1 쿼리 탐지 결과

   ### 발견된 문제 (3건)

   1. **src/services/user.service.ts:45**
      - 패턴: 루프 내 쿼리
      - 심각도: HIGH
      - 수정 제안: [코드]

   ### 요약
   - 총 스캔 파일: 24개
   - 발견된 N+1 패턴: 3개
   - 예상 쿼리 감소: ~50회 → 3회
   ```
