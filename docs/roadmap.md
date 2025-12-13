# 개발 및 마케팅 로드맵 (Roadmap Checklist)

본 문서는 `project_proposal.md`를 기반으로 한 실행 가능한 상세 로드맵입니다.

## Phase 1: MVP 개발 (Offline First)
> 목표: 핵심 가치(위치 기록, 복구 습관)를 검증하는 오프라인 전용 앱 출시

### 기획 및 디자인 (Planning & Design)
- [ ] **Data Structure Design**
    - [ ] 계층적(Tree) 공간 구조 모델링 (Recursive Data Model)
    - [ ] 물건(Item) 및 로그(Log) 엔티티 설계
- [ ] **UI/UX Design**
    - [ ] 메인 홈 (현재 상태 대시보드)
    - [ ] 공간/물건 등록 흐름 (Wizard UI)
    - [ ] 검색 및 상세 화면

### 클라이언트 개발 (Flutter Implementation)
- [ ] **Project Setup**
    - [ ] Flutter 프로젝트 생성 및 구조 잡기
    - [ ] Local DB 세팅 (Hive or Drift)
    - [ ] State Management 세팅 (Riverpod/Bloc)
- [ ] **Core Features**
    - [ ] 공간(Space) CRUD 구현 (계층 구조 지원)
    - [ ] 물건(Item) CRUD 구현 (이미지 저장 포함)
    - [ ] 검색 기능 (Breadcrumb path 표시)
- [ ] **Usage Features**
    - [ ] 사용하기(Check-out) / 복구하기(Restore) 액션 구현
    - [ ] 로컬 푸시 알림 스케줄링 (미복구 리마인더)

### 테스트 및 배포 (Test & Release)
- [ ] 내부 QA (기능 테스트)
- [ ] 구글 플레이스토어 / 앱스토어 배포 (1.0.0)

---

## Phase 2: 연결과 확장 (Online & Family)
> 목표: 데이터 동기화 및 가족 간 공유 기능을 통한 사용성 확대 / 사용자 잠금(Lock-in)

### 백엔드 및 연동 (Backend & Sync)
- [ ] **Supabase Setup**
    - [ ] Auth 설정 (Email, Google, Kakao)
    - [ ] DB Table 설계 및 RLS(Row Level Security) 정책 수립
- [ ] **Synchronization Logic**
    - [ ] 로컬 데이터 -> 서버 마이그레이션 로직 구현
    - [ ] 양방향 동기화 (Conflict Resolution) 구현
    - [ ] 오프라인 대응 (큐잉 시스템)

### 확장 기능 (Expansion)
- [ ] **Family Sharing**
    - [ ] 가족 그룹 생성 및 초대 링크/코드 기능
    - [ ] 그룹 내 물건/공간 권한 관리
    - [ ] "누가 쓰고 있나" 실시간 상태 표시
- [ ] **Tagging**
    - [ ] NFC/QR 코드 스캔 기능 구현

---

## Phase 3: 마케팅 및 성장 (Marketing & Growth)
> 목표: 사용자 확보 및 리텐션 강화

### 콘텐츠 마케팅 (Content Marketing)
- [ ] **SNS 콘텐츠 제작**
    - [ ] 숏폼 시나리오 기획 ("30분 찾을 거 1초 만에 찾기")
    - [ ] 영상 촬영 및 편집
- [ ] **바이럴 마케팅**
    - [ ] 자취생/인테리어 커뮤니티 배포용 원고 작성
    - [ ] 체험단 모집 (초기 유저 피드백 확보)

### 리텐션 강화 (Retention)
- [ ] **Gamification**
    - [ ] "7일 연속 정리 챌린지" 배지 시스템 기획 및 개발
- [ ] **UX Writing 개선**
    - [ ] 위트 있는 푸시 알림 문구 A/B 테스트
