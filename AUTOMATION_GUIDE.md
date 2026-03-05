# 🤖 Automation Guide – Hướng dẫn Tự động hóa

Hướng dẫn automation trong phát triển phần mềm và cách áp dụng vào dự án React + .NET Core.

---

## 🧪 Dành cho Tester: Đi đâu trước?

| Mục tiêu | Đi tới section |
|----------|----------------|
| **Roadmap học Automation Test** (từ zero → có thể viết & chạy automation) | [§ Roadmap Automation Test cho Tester](#roadmap-automation-test-cho-tester) |
| Khái niệm Testing (pyramid, unit/integration/E2E) | [§ 3. Testing Automation](#3-testing-automation) |
| Công cụ & ví dụ test Backend (.NET) | [§ 3.3. Backend Testing](#33-backend-testing-net-core) |
| Công cụ & ví dụ test Frontend (React) | [§ 3.4. Frontend Testing](#34-frontend-testing-react) |
| Đưa test vào pipeline (CI) | [§ 2. CI/CD](#2-cicd---continuous-integration--deployment) |

---

## 📋 Mục lục

1. [Giới thiệu về Automation](#1-giới-thiệu-về-automation)
2. [CI/CD – Continuous Integration & Deployment](#2-cicd---continuous-integration--deployment)
3. [Testing Automation](#3-testing-automation)
4. [Code Quality Automation](#4-code-quality-automation)
5. [Build & Release Automation](#5-build--release-automation)
6. [Monitoring & Alerting Automation](#6-monitoring--alerting-automation)
7. [Infrastructure as Code (IaC)](#7-infrastructure-as-code-iac)
8. [DevOps Tools Stack](#8-devops-tools-stack)
9. [Roadmap Automation Test cho Tester](#roadmap-automation-test-cho-tester)
10. [Best Practices](#10-best-practices)
11. [Tài liệu tham khảo](#-tài-liệu-tham-khảo)

---

## 1. Giới thiệu về Automation

### 1.1. Automation là gì?

**Automation** (Tự động hóa) là quá trình sử dụng công cụ, scripts và workflows để tự động thực hiện các tác vụ lặp đi lặp lại trong quy trình phát triển phần mềm, giảm thiểu sự can thiệp thủ công của con người.

### 1.2. Tại sao cần Automation?

#### Lợi ích:

- ✅ **Tiết kiệm thời gian**: Không cần làm thủ công các tác vụ lặp lại
- ✅ **Giảm lỗi**: Loại bỏ lỗi do con người (human error)
- ✅ **Tăng tốc độ**: Release nhanh hơn và thường xuyên hơn (có thể deploy nhiều lần/ngày)
- ✅ **Chất lượng code**: Đảm bảo code luôn đạt chuẩn trước khi merge
- ✅ **Tính nhất quán**: Môi trường và quy trình giống nhau mọi lúc
- ✅ **Khả năng mở rộng**: Dễ dàng scale khi team lớn hơn
- ✅ **Truy xuất nguồn gốc**: Dễ dàng trace lại các thay đổi và deployment

#### Khi nào nên dùng Automation?

- Khi bạn làm điều gì đó **3 lần trở lên** → Nên tự động hóa
- Các tác vụ **lặp đi lặp lại** → Tự động hóa
- Các tác vụ **dễ bị quên** → Tự động hóa (như chạy tests trước khi commit)
- Các tác vụ **phức tạp, dễ sai sót** → Tự động hóa

### 1.3. Các loại Automation trong Software Development

1. **CI/CD** - Tự động build, test, và deploy
2. **Testing** - Tự động chạy tests
3. **Code Quality** - Tự động kiểm tra code quality
4. **Security Scanning** - Tự động quét lỗ hổng bảo mật
5. **Infrastructure** - Tự động tạo và quản lý infrastructure
6. **Monitoring** - Tự động giám sát và cảnh báo
7. **Documentation** - Tự động generate documentation
8. **Dependency Updates** - Tự động update dependencies

---

## 2. CI/CD - Continuous Integration & Deployment

### 2.1. CI/CD là gì?

#### CI (Continuous Integration) - Tích hợp liên tục

- **Định nghĩa**: Tự động build và test code mỗi khi có commit/pull request
- **Mục đích**: Phát hiện lỗi sớm, đảm bảo code luôn ở trạng thái có thể build được
- **Khi nào chạy**: 
  - Mỗi khi có push vào branch
  - Mỗi khi có pull request
  - Có thể schedule (chạy định kỳ)

**Quy trình CI:**
```
Developer commits code
    ↓
Git push to repository
    ↓
CI Server detects changes
    ↓
Run automated tests
    ↓
Build application
    ↓
Run code quality checks
    ↓
Generate reports
    ↓
Notify team (pass/fail)
```

#### CD (Continuous Deployment) - Triển khai liên tục

- **Định nghĩa**: Tự động deploy code lên môi trường production sau khi pass tất cả tests
- **Mục đích**: Release nhanh, giảm rủi ro deploy thủ công
- **Khi nào chạy**: Sau khi CI pass, có thể cần manual approval

**Quy trình CD:**
```
CI passes successfully
    ↓
Deploy to Staging environment
    ↓
Run integration/E2E tests
    ↓
Manual approval (optional)
    ↓
Deploy to Production
    ↓
Health checks
    ↓
Rollback if fails
```

### 2.2. CI/CD Pipeline Components

#### Các bước trong Pipeline:

1. **Source** - Lấy code từ repository
2. **Build** - Compile/build application
3. **Test** - Chạy unit tests, integration tests
4. **Quality Check** - Lint, code coverage, security scan
5. **Package** - Tạo artifacts (Docker images, build files)
6. **Deploy Staging** - Deploy lên môi trường staging
7. **E2E Tests** - Chạy end-to-end tests
8. **Deploy Production** - Deploy lên production (có thể cần approval)
9. **Monitoring** - Giám sát sau khi deploy

### 2.3. CI/CD Tools phổ biến

#### Cloud-based (Khuyến nghị cho beginners):

1. **GitHub Actions** ⭐ (Đã có sẵn trong dự án)
   - Miễn phí cho public repos
   - Tích hợp sẵn với GitHub
   - Dễ setup, không cần server riêng
   
2. **GitLab CI/CD**
   - Miễn phí, mạnh mẽ
   - Tích hợp với GitLab
   
3. **Azure DevOps**
   - Tích hợp tốt với Microsoft ecosystem
   - Free tier cho small teams
   
4. **CircleCI**
   - Free tier có giới hạn
   - Dễ sử dụng

#### Self-hosted:

1. **Jenkins** ⭐
   - Miễn phí, open-source
   - Rất linh hoạt, nhiều plugins
   - Cần server riêng để chạy
   
2. **TeamCity**
   - Commercial, có free tier
   - User-friendly

### 2.4. GitHub Actions - Cơ bản

#### Cấu trúc file:

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      - run: npm install
      - run: npm run build
```

#### Các concepts quan trọng:

- **Workflow**: File YAML định nghĩa pipeline
- **Job**: Nhóm các steps chạy trên cùng 1 runner
- **Step**: Một tác vụ cụ thể (run command, use action)
- **Action**: Reusable code (checkout, setup-node, etc.)
- **Runner**: Server chạy jobs (GitHub-hosted hoặc self-hosted)

### 2.5. CI/CD Best Practices

- ✅ **Fail fast**: Dừng ngay khi có lỗi, không tiếp tục
- ✅ **Parallel jobs**: Chạy tests song song để nhanh hơn
- ✅ **Cache dependencies**: Cache node_modules, NuGet packages
- ✅ **Artifacts**: Lưu build artifacts để dùng sau
- ✅ **Environment variables**: Dùng secrets cho sensitive data
- ✅ **Branch protection**: Yêu cầu CI pass trước khi merge
- ✅ **Rollback strategy**: Có kế hoạch rollback khi deploy fail

---

## 3. Testing Automation

### 3.1. Tại sao cần Test Automation?

- **Phát hiện lỗi sớm**: Lỗi được phát hiện ngay sau khi code thay đổi
- **Tiết kiệm thời gian**: Không cần test thủ công mọi thứ
- **Tự tin khi refactor**: Biết ngay khi phá vỡ functionality
- **Documentation**: Tests là documentation sống về cách code hoạt động
- **Regression prevention**: Tránh lỗi cũ quay lại

### 3.2. Testing Pyramid

```
        /\
       /  \         E2E Tests (ít, chậm, expensive)
      /____\
     /      \       Integration Tests (vừa phải)
    /________\
   /          \     Unit Tests (nhiều, nhanh, rẻ)
  /____________\
```

#### Unit Tests (Nhiều nhất - 70%)

- Test từng function/method riêng lẻ
- Nhanh, chạy hàng nghìn tests trong vài giây
- Ví dụ: Test function tính tổng, validate input

#### Integration Tests (Vừa phải - 20%)

- Test sự tương tác giữa các components
- Chậm hơn unit tests
- Ví dụ: Test API endpoint với database

#### E2E Tests (Ít nhất - 10%)

- Test toàn bộ flow từ user perspective
- Chậm nhất, tốn tài nguyên nhất
- Ví dụ: Test user đăng nhập → mua hàng → thanh toán

### 3.3. Backend Testing (.NET Core)

#### Tools:

1. **xUnit** ⭐ (Khuyến nghị)
   - Modern, async support tốt
   - Syntax dễ đọc
   
2. **NUnit**
   - Phổ biến, nhiều features
   
3. **MSTest**
   - Built-in với Visual Studio

#### Testing Libraries:

- **Moq** - Mocking framework
- **FluentAssertions** - Assertions dễ đọc hơn
- **AutoFixture** - Tự động tạo test data
- **Bogus** - Fake data generator

#### Cấu trúc Test Project:

```
Genshin.API.Tests/
├── Controllers/
│   └── WeatherForecastControllerTests.cs
├── Services/
│   └── SomeServiceTests.cs
├── Integration/
│   └── ApiIntegrationTests.cs
└── Helpers/
    └── TestDataBuilder.cs
```

#### Ví dụ Unit Test:

```csharp
[Fact]
public void GetWeatherForecast_ReturnsFiveItems()
{
    // Arrange
    var controller = new WeatherForecastController(_logger);
    
    // Act
    var result = controller.Get();
    
    // Assert
    Assert.Equal(5, result.Count());
}
```

### 3.4. Frontend Testing (React)

#### Tools:

1. **Vitest** ⭐ (Khuyến nghị cho Vite)
   - Fast, compatible với Jest
   - Tích hợp tốt với Vite
   
2. **Jest**
   - Phổ biến nhất
   - Nhiều features
   
3. **Testing Library**
   - Test như user sử dụng
   - Khuyến nghị bởi React team

#### E2E Testing:

1. **Playwright** ⭐ (Khuyến nghị)
   - Modern, fast
   - Multi-browser support
   
2. **Cypress**
   - Popular, easy to use
   - Good documentation
   
3. **Selenium**
   - Classic, mature

#### Ví dụ Component Test:

```typescript
test('renders app title', () => {
  render(<App />)
  expect(screen.getByText('Genshin Project')).toBeInTheDocument()
})
```

### 3.5. Test Coverage

- **Code Coverage**: Phần trăm code được test
- **Mục tiêu**: 
  - Unit tests: 80%+
  - Overall: 70%+
- **Tools**: 
  - Backend: coverlet, ReportGenerator
  - Frontend: vitest --coverage, istanbul

### 3.6. Testing Best Practices

- ✅ **AAA Pattern**: Arrange, Act, Assert
- ✅ **One assertion per test**: Mỗi test chỉ test 1 thing
- ✅ **Test names rõ ràng**: `GetWeatherForecast_WhenCalled_ReturnsFiveItems`
- ✅ **Independent tests**: Tests không phụ thuộc vào nhau
- ✅ **Fast tests**: Unit tests phải chạy nhanh
- ✅ **Mock external dependencies**: Database, API calls, file system

---

## 4. Code Quality Automation

### 4.1. Linting & Formatting

#### Backend (.NET Core):

**Roslyn Analyzers**:
- Built-in với .NET
- Cảnh báo về code style, best practices

**StyleCop**:
- Enforce coding standards
- Configurable rules

**EditorConfig**:
- Consistent code style across team

#### Frontend (React/TypeScript):

**ESLint**:
- Tìm lỗi code
- Enforce coding standards
- 100+ rules

**Prettier**:
- Code formatter
- Tự động format code
- Không kiểm tra logic, chỉ format

**TSC (TypeScript Compiler)**:
- Type checking
- Tìm type errors

### 4.2. Code Review Automation

#### SonarQube / SonarCloud:

- Code quality analysis
- Security vulnerabilities
- Code smells
- Technical debt tracking
- Coverage reports

**Tích hợp với CI/CD**:
- Chạy analysis sau mỗi PR
- Block merge nếu có critical issues

### 4.3. Git Hooks

#### Pre-commit Hooks:

Chạy trước khi commit:
- Lint code
- Format code
- Run tests
- Check commit message format

**Tools**:
- **Husky** (Node.js) - Git hooks made easy
- **pre-commit** (Python) - Framework cho pre-commit hooks

#### Commit-msg Hooks:

- Validate commit message format
- Enforce conventional commits

### 4.4. Dependency Scanning

#### Security Vulnerabilities:

**Tools**:
- **npm audit** - Check npm packages
- **dotnet list package --vulnerable** - Check NuGet packages
- **Snyk** - Security scanning
- **Dependabot** - Auto-update dependencies

**Tích hợp vào CI/CD**:
- Chạy security scan mỗi PR
- Fail nếu có critical vulnerabilities

### 4.5. Code Quality Metrics

- **Cyclomatic Complexity**: Độ phức tạp của code
- **Code Duplication**: Trùng lặp code
- **Maintainability Index**: Độ dễ bảo trì
- **Technical Debt**: Nợ kỹ thuật

---

## 5. Build & Release Automation

### 5.1. Semantic Versioning

**Format**: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (1.0.0 → 2.0.0)
- **MINOR**: New features, backward compatible (1.0.0 → 1.1.0)
- **PATCH**: Bug fixes (1.0.0 → 1.0.1)

**Conventional Commits**:
- `feat:` → MINOR version
- `fix:` → PATCH version
- `BREAKING CHANGE:` → MAJOR version

**Tools**:
- **semantic-release** - Auto versioning từ commits
- **commitlint** - Validate commit messages

### 5.2. Automated Releases

**Workflow**:
1. Developer push code
2. CI/CD runs
3. Auto bump version based on commits
4. Create Git tag
5. Create GitHub Release
6. Generate changelog
7. Publish artifacts

### 5.3. Docker Image Automation

**Workflow**:
1. Build Docker image
2. Tag with version
3. Push to registry (Docker Hub, GitHub Container Registry)
4. Update deployment configs

**Multi-stage builds**:
- Build stage: Compile code
- Runtime stage: Chỉ chứa runtime dependencies

### 5.4. Artifact Management

**Store**:
- **GitHub Artifacts** - Built-in với GitHub Actions
- **Nexus** - Enterprise artifact repository
- **Artifactory** - Universal artifact management

---

## 6. Monitoring & Alerting Automation

### 6.1. Application Performance Monitoring (APM)

**Tools**:
- **Application Insights** (Azure)
- **New Relic**
- **Datadog**
- **Sentry** (Error tracking) ⭐

**Metrics**:
- Response time
- Error rate
- Throughput
- Resource usage (CPU, Memory)

### 6.2. Logging

**Centralized Logging**:
- **ELK Stack** (Elasticsearch, Logstash, Kibana)
- **Loki + Grafana**
- **Splunk**

**Structured Logging**:
- JSON format
- Searchable, filterable
- Context information

### 6.3. Uptime Monitoring

**Tools**:
- **UptimeRobot** - Free tier available
- **Pingdom**
- **StatusCake**

**Checks**:
- HTTP endpoint health
- SSL certificate expiry
- API response time

### 6.4. Automated Alerts

**Channels**:
- Email
- Slack
- Discord
- Telegram
- Microsoft Teams
- PagerDuty (for critical issues)

**Alert Rules**:
- Error rate > threshold
- Response time > threshold
- Disk space < 20%
- Memory usage > 80%

---

## 7. Infrastructure as Code (IaC)

### 7.1. IaC là gì?

Định nghĩa và quản lý infrastructure bằng code thay vì thủ công.

**Lợi ích**:
- Version control cho infrastructure
- Reproducible environments
- Faster provisioning
- Reduce human error

### 7.2. Tools

#### Terraform ⭐

- Declarative syntax (HCL)
- Multi-cloud support
- State management
- Plan before apply

**Ví dụ**:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

#### Ansible

- Agentless
- YAML-based
- Great for configuration management
- Idempotent

#### Pulumi

- Use real programming languages (TypeScript, Python, Go)
- Type-safe
- Modern approach

### 7.3. Container Orchestration

**Kubernetes**:
- Auto-scaling
- Self-healing
- Rolling updates
- Service discovery

**Helm**:
- Package manager cho Kubernetes
- Templates cho Kubernetes manifests

---

## 8. DevOps Tools Stack

### 8.1. Recommended Stack

#### CI/CD:
- **GitHub Actions** - For GitHub repos
- **GitLab CI** - If using GitLab
- **Jenkins** - Self-hosted option

#### Containers:
- **Docker** - Containerization
- **Docker Compose** - Multi-container apps
- **Kubernetes** - Orchestration (advanced)

#### IaC:
- **Terraform** - Infrastructure provisioning
- **Ansible** - Configuration management

#### Monitoring:
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **ELK Stack** - Logging

#### APM:
- **Sentry** - Error tracking
- **Application Insights** - Azure monitoring

### 8.2. Tool Selection Criteria

- **Ease of use**: Dễ học và sử dụng
- **Community support**: Active community
- **Integration**: Tích hợp với tools khác
- **Cost**: Free vs paid
- **Scalability**: Có thể scale không

---

<a id="roadmap-automation-test-cho-tester"></a>

## 9. Roadmap Automation Test cho Tester

Roadmap này dành cho **tester** muốn học automation test từ nền tảng đến có thể viết script, đưa vào CI và mở rộng sang API/E2E.

**Ước lượng tổng:** ~10–16 tuần (tuỳ tốc độ và thời gian dành mỗi ngày). Có thể rút ngắn nếu đã biết lập trình cơ bản.

---

### Tổng quan roadmap

| Phase | Nội dung | Thời gian gợi ý | Deliverable |
|-------|----------|------------------|-------------|
| 0 | Nền tảng (manual + test design) | 1–2 tuần | Test cases rõ ràng, hiểu pyramid |
| 1 | Programming & automation cơ bản | 2–3 tuần | Script đơn giản (API hoặc UI) |
| 2 | API Automation | 2–3 tuần | Bộ test API chạy được local + trong CI |
| 3 | UI / E2E Automation | 3–4 tuần | E2E flow chính chạy ổn định |
| 4 | CI & reporting | 1–2 tuần | Pipeline chạy test + report |
| 5 | Nâng cao (tuỳ chọn) | 2–4 tuần | Pattern, framework, maintainability |

---

### Phase 0: Nền tảng (Manual + Test design)

**Mục tiêu:** Vững cách nghĩ test, biết test cái gì trước khi automation.

- [ ] **Test design:** Biết viết test case (Given-When-Then hoặc steps rõ ràng).
- [ ] **Test pyramid:** Hiểu Unit vs Integration vs E2E (xem [§ 3. Testing Automation](#3-testing-automation)).
- [ ] **Ưu tiên:** Biết chọn test nào nên automate trước (critical path, regression, lặp lại nhiều).
- [ ] **Bug & environment:** Quen report bug, biết môi trường dev/staging (URL, data test).

**Không cần code** – chỉ cần thói quen phân tích và ghi rõ kịch bản test.

---

### Phase 1: Programming & Automation cơ bản

**Mục tiêu:** Đủ kiến thức lập trình để đọc/viết test script (không cần thành dev).

**Học:**

- [ ] **Ngôn ngữ:** Chọn **một** hướng phù hợp dự án:
  - **Backend/.NET:** C# cơ bản (biến, if/loop, class, method).
  - **Frontend/React:** JavaScript hoặc TypeScript cơ bản (biến, function, async).
- [ ] **CLI:** Chạy lệnh trong terminal (mở folder project, chạy `dotnet test` hoặc `npm test`).
- [ ] **Git cơ bản:** clone, pull, branch, commit (để đưa test code vào repo và CI).

**Thực hành:**

- [ ] Chạy bộ test có sẵn của dự án (Backend: xUnit, Frontend: Vitest/Jest).
- [ ] Sửa 1 test có sẵn (đổi expected, tên test) và chạy lại.
- [ ] Viết 1 test mới đơn giản (ví dụ: gọi 1 API bằng tool Postman/Insomnia, rồi chuyển thành 1 script test).

**Tài liệu gợi ý:**

- C#: Microsoft Learn “C# for Beginners”.
- JS/TS: freeCodeCamp hoặc “JavaScript.info”.
- Git: “Pro Git” (free online).

---

### Phase 2: API Automation

**Mục tiêu:** Có bộ test API ổn định, chạy local và trong CI.

**Học:**

- [ ] **HTTP cơ bản:** Method (GET/POST/PUT/DELETE), status code, header, body (JSON).
- [ ] **Công cụ hoặc thư viện (chọn một hướng):**
  - **.NET:** xUnit + `HttpClient` hoặc RestSharp; hoặc Postman → export/Newman.
  - **Node/JS:** Vitest/Jest + `fetch` hoặc axios; hoặc Postman/Newman.
- [ ] **Assertions:** So sánh status code, body (JSON), thời gian phản hồi nếu cần.
- [ ] **Data & environment:** Dùng config (base URL, token) qua env hoặc config file, không hardcode.

**Thực hành:**

- [ ] Viết 3–5 test API cho các endpoint quan trọng (login, CRUD chính).
- [ ] Test pass/fail ổn định khi chạy nhiều lần (không phụ thuộc thứ tự hoặc data tạm).
- [ ] Chạy được bằng lệnh: `dotnet test` hoặc `npm run test:api`.

**Tài liệu:** xUnit docs, RestSharp/HttpClient, Postman Learning Center.

---

### Phase 3: UI / E2E Automation

**Mục tiêu:** Tự động được vài flow E2E chính (đăng nhập, flow nghiệp vụ quan trọng).

**Học:**

- [ ] **E2E là gì:** Chạy trên browser, mô phỏng user (click, nhập, chờ element).
- [ ] **Công cụ (chọn một):**
  - **Playwright** (khuyến nghị): cài, viết script, chạy headless/headed.
  - **Cypress:** nếu team đã dùng.
- [ ] **Selector:** ID, class, data-testid, text; tránh selector dễ vỡ (quá phụ thuộc CSS phức tạp).
- [ ] **Wait:** Chờ element visible/clickable thay vì sleep cố định.
- [ ] **Page Object (sơ bộ):** Tách selector và action theo từng màn hình để dễ bảo trì.

**Thực hành:**

- [ ] 1 test: mở app → login → kiểm tra vào được dashboard (hoặc trang chính).
- [ ] 1 test: flow nghiệp vụ chính (ví dụ: tạo đơn, xem danh sách).
- [ ] Chạy ổn định trên 1 browser (Chrome hoặc Chromium); sau có thể mở rộng.

**Tài liệu:** Playwright docs, Cypress docs, “Test Automation University” (free).

---

### Phase 4: Đưa test vào CI & báo cáo

**Mục tiêu:** Mỗi lần push/PR, test tự chạy và có kết quả rõ ràng.

**Học:**

- [ ] **CI cơ bản:** Workflow chạy khi push/PR (xem [§ 2. CI/CD](#2-cicd---continuous-integration--deployment)).
- [ ] **GitHub Actions (hoặc GitLab CI):** Cấu hình job chạy `dotnet test` / `npm run test` / `npx playwright test`.
- [ ] **Artifacts:** Lưu report (JUnit XML, HTML, screenshot khi fail) và xem trong CI.
- [ ] **Branch protection:** Merge chỉ khi CI pass (do team/lead cấu hình).

**Thực hành:**

- [ ] Tạo workflow chạy API tests mỗi khi push vào `main` (hoặc develop).
- [ ] Thêm bước chạy E2E (có thể chạy ít hơn, ví dụ chỉ khi merge vào `main`).
- [ ] Mở report (HTML hoặc screenshot) khi test fail để debug.

**Tài liệu:** GitHub Actions docs, GitLab CI docs.

---

### Phase 5: Nâng cao (tuỳ chọn)

**Mục tiêu:** Dễ bảo trì, mở rộng và hợp tác với dev.

- [ ] **Framework/pattern:** Page Object rõ ràng, shared fixtures, config theo environment.
- [ ] **Data:** Test data tách riêng (file JSON/CSV), có thể dùng fake data (Faker).
- [ ] **Parallel & speed:** Chạy test song song (theo tool), giảm thời gian E2E.
- [ ] **Reporting:** Allure, ReportPortal hoặc report custom (screenshot + log).
- [ ] **API + UI kết hợp:** Setup trạng thái qua API rồi E2E chỉ verify UI (nhanh hơn).

---

### Checklist tổng cho Tester

- [ ] Phase 0: Test design & pyramid rõ ràng.
- [ ] Phase 1: Chạy và sửa/viết 1 test đơn giản.
- [ ] Phase 2: Có bộ API tests, chạy local + trong CI.
- [ ] Phase 3: Có ít nhất 1–2 E2E flow ổn định.
- [ ] Phase 4: CI chạy test tự động và có report.
- [ ] Phase 5 (tuỳ chọn): Cấu trúc và báo cáo tốt hơn.

**Gợi ý:** Làm song song với dự án thật (React + .NET của repo này). Bắt đầu từ API (Phase 2) thường nhanh có giá trị hơn E2E (Phase 3).

---

## 10. Best Practices

### 10.1. General Principles

- ✅ **Start small**: Bắt đầu với automation đơn giản, rồi mở rộng
- ✅ **Fail fast**: Dừng ngay khi có lỗi
- ✅ **Idempotent**: Chạy nhiều lần cho cùng kết quả
- ✅ **Version control**: Mọi thứ đều trong Git
- ✅ **Documentation**: Document automation workflows
- ✅ **Security**: Không commit secrets, dùng environment variables

### 10.2. CI/CD Best Practices

- ✅ **Fast feedback**: Pipeline phải chạy nhanh (< 10 phút)
- ✅ **Parallel execution**: Chạy jobs song song
- ✅ **Cache everything**: Cache dependencies
- ✅ **Branch protection**: Require CI pass before merge
- ✅ **Separate environments**: Dev → Staging → Production
- ✅ **Blue-green deployment**: Zero downtime

### 10.3. Testing Best Practices

- ✅ **Test pyramid**: Nhiều unit tests, ít E2E tests
- ✅ **Fast tests**: Unit tests < 1 second
- ✅ **Isolated tests**: Không phụ thuộc vào nhau
- ✅ **Meaningful names**: Test names rõ ràng
- ✅ **Mock external dependencies**: Database, APIs
- ✅ **Maintain test coverage**: > 70%

### 10.4. Code Quality Best Practices

- ✅ **Consistent style**: Cùng format cho cả team
- ✅ **Automated formatting**: Prettier tự động format
- ✅ **Lint before commit**: Git hooks
- ✅ **Code review**: Always review before merge
- ✅ **Technical debt tracking**: Track và fix dần

---

## 📚 Tài liệu tham khảo

### Sách:
- "The DevOps Handbook" - Gene Kim
- "Continuous Delivery" - Jez Humble
- "The Phoenix Project" - Gene Kim

### Khóa học miễn phí:
- GitHub Skills (GitHub Actions)
- Microsoft Learn - DevOps
- Kubernetes Tutorial

### Blogs & Resources:
- DevOps.com
- Martin Fowler's Blog
- ThoughtWorks Technology Radar

### Tools Documentation:
- GitHub Actions Docs
- Docker Documentation
- Terraform Documentation
- Kubernetes Documentation

---

## 🎯 Bước tiếp theo

**Nếu bạn là Tester:**

1. Đọc [Roadmap Automation Test cho Tester](#roadmap-automation-test-cho-tester) và chọn phase phù hợp level hiện tại.
2. Ưu tiên **Phase 0 + Phase 2 (API Automation)** để nhanh có giá trị.
3. Dùng chính dự án React + .NET trong repo này để thực hành (chạy test, viết thêm API test, rồi CI).

**Nếu bạn đảm nhiệm cả DevOps/automation chung:**

1. Bắt đầu với CI/CD (section 2), sau đó Testing (section 3) và Code Quality (section 4).
2. Setup môi trường: GitHub Actions, chạy test trong pipeline.
3. Mở rộng dần: deployment, monitoring (sections 5–6).

**Nhớ:** Automation là quá trình tích lũy, không cần làm hết mọi thứ cùng lúc. Ưu tiên theo vai trò (tester vs devops) và nhu cầu dự án.

