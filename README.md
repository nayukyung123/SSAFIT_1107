# SSAFIT_1107

📚 운동 추천 및 리뷰 서비스 데이터베이스 스키마 정의

1. 개요 및 설계 원칙

본 스키마는 운동 영상 콘텐츠를 중심으로 사용자 관리, 운동 추천(부위별), 리뷰, 커뮤니티, 운동 계획 및 기록 관리 등 서비스의 5대 핵심 기능을 지원하도록 설계되었습니다.

DBMS: MySQL

테이블 수: 9개

주요 원칙: 모든 기본 키(PK)에 AUTO_INCREMENT를 적용하여 데이터의 무결성과 관리 편의성을 확보했습니다.

2. 주요 엔티티 및 관계 도출 근거

엔티티 (테이블)

서비스 기능 매핑

설계 근거 (관계)

Users

전 기능의 주체

모든 서비스 활동(리뷰, 계획, 게시글)의 주체이므로, 다른 모든 핵심 테이블과 1:N 관계를 가집니다.

Videos

운동 영상 관리, 검색, 추천

운동 서비스의 핵심 콘텐츠입니다. 부위별 추천을 위해 VideoBodyParts와 N:M 관계를 가집니다.

VideoBodyParts

부위별 검색 및 추천

Videos와 운동 부위 간의 다대다(N:M) 관계를 해소하고, 하나의 영상에 여러 부위를 연결하기 위한 연결 테이블입니다.

Reviews

영상 평점 및 리뷰

Videos와 Users 간의 다대다(N:M) 관계를 해소하며, 리뷰 콘텐츠(content, rating)와 작성 시간(created_at)을 저장합니다.

WorkoutPlans

운동 계획 관리

사용자는 여러 개의 계획을 가질 수 있으므로 Users와 1:N 관계를 가집니다.

PlanItems

계획-영상 연결

WorkoutPlans와 Videos 간의 다대다(N:M) 관계를 해소하고, 계획 내 영상의 순서(order_index)를 정의하기 위한 연결 테이블입니다.

WorkoutHistory

운동 기록 관리

사용자의 운동 이력 통계 산출을 위해 Users와 1:N 관계를 가집니다. plan_id를 참조하여 어떤 계획을 수행했는지 기록합니다.

CommunityPosts

커뮤니티 기능

Users와 1:N 관계를 가지며, 댓글 기능을 위해 CommunityComments와 1:N 관계를 가집니다.

3. 테이블 상세 구조 및 관계

테이블명

주요 목적

PK 컬럼

FK 관계

주요 컬럼 및 기능

Users

서비스 사용자 정보

user_id

-

username, email, level (운동 수준)

Videos

운동 영상 원본 정보

video_id

-

title, url, duration_seconds, difficulty (난이도)

VideoBodyParts

부위별 검색 지원

video_body_part_id

video_id (Videos)

body_part (운동 부위 명칭)

Reviews

영상 평점 및 리뷰

review_id

video_id (Videos), user_id (Users)

rating (1~5점), content

WorkoutPlans

사용자 운동 루틴 관리

plan_id

user_id (Users)

plan_name, description

PlanItems

루틴 구성 영상

plan_item_id

plan_id (WorkoutPlans), video_id (Videos)

order_index (루틴 내 순서)

WorkoutHistory

운동 완료 기록

history_id

user_id (Users), plan_id (WorkoutPlans)

completion_date, duration_minutes (실제 수행 시간)

CommunityPosts

커뮤니티 게시글

post_id

user_id (Users)

title, content, views (조회수)

CommunityComments

게시글 댓글

comment_id

post_id (CommunityPosts), user_id (Users)

content

4. 핵심 기능별 컬럼 정의 상세

테이블명

컬럼명

타입

설명

Videos

difficulty

INT

영상의 운동 난이도를 1(쉬움)에서 5(어려움) 사이로 정의하여 추천 알고리즘의 기준 제공

VideoBodyParts

body_part

VARCHAR(50)

영상이 다루는 운동 부위(예: 하체, 코어)를 명시하여 부위별 필터링에 활용

Reviews

rating

INT

사용자 평가 점수 (1~5점), 영상의 평점 산출의 기초 데이터

WorkoutHistory

plan_id

INT

FK, 사용자가 완료한 전체 계획(루틴)을 참조. (NULL 허용: 단일 영상 운동 기록용)

WorkoutHistory

duration_minutes

INT

사용자가 해당 운동을 실제로 수행한 시간을 기록하여 통계 데이터 산출
