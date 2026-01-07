# 🤖 Automation Guide - Hướng dẫn Tự động hóa

Hướng dẫn chi tiết về automation trong phát triển phần mềm và cách implement vào dự án React + .NET Core.

## 📋 Mục lục

1. [Giới thiệu về Automation](#1-giới-thiệu-về-automation)
2. [CI/CD - Continuous Integration & Deployment](#2-cicd---continuous-integration--deployment)
3. [Testing Automation](#3-testing-automation)
4. [Code Quality Automation](#4-code-quality-automation)
5. [Build & Release Automation](#5-build--release-automation)
6. [Monitoring & Alerting Automation](#6-monitoring--alerting-automation)
7. [Infrastructure as Code (IaC)](#7-infrastructure-as-code-iac)
8. [DevOps Tools Stack](#8-devops-tools-stack)
9. [Roadmap Học Automation](#9-roadmap-học-automation)
10. [Best Practices](#10-best-practices)

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

## 9. Roadmap Học Automation

### Phase 1: CI/CD Basics (2-3 tuần)

**Mục tiêu**: Hiểu và setup CI/CD pipeline cơ bản

**Học:**
- [ ] GitHub Actions cơ bản
- [ ] YAML syntax
- [ ] Workflow triggers (push, PR, schedule)
- [ ] Jobs và steps
- [ ] Artifacts và caching

**Thực hành:**
- [ ] Setup CI pipeline cho dự án hiện tại
- [ ] Tự động build Frontend và Backend
- [ ] Tự động chạy tests (nếu có)

**Tài liệu:**
- GitHub Actions Documentation
- YouTube: "GitHub Actions Tutorial"

### Phase 2: Testing Automation (3-4 tuần)

**Mục tiêu**: Viết và tự động hóa tests

**Học:**
- [ ] Unit testing concepts
- [ ] Testing frameworks (xUnit, Vitest)
- [ ] Mocking và stubbing
- [ ] Test coverage
- [ ] Integration testing

**Thực hành:**
- [ ] Viết unit tests cho Backend
- [ ] Viết component tests cho Frontend
- [ ] Setup test coverage reporting
- [ ] Tích hợp tests vào CI pipeline

**Tài liệu:**
- xUnit documentation
- Testing Library documentation
- "The Art of Unit Testing" book

### Phase 3: Code Quality (2-3 tuần)

**Mục tiêu**: Tự động kiểm tra code quality

**Học:**
- [ ] ESLint và Prettier
- [ ] Git hooks (Husky)
- [ ] SonarQube/SonarCloud
- [ ] Code review automation

**Thực hành:**
- [ ] Setup ESLint cho Frontend
- [ ] Setup Prettier
- [ ] Setup pre-commit hooks
- [ ] Tích hợp SonarCloud vào CI

**Tài liệu:**
- ESLint documentation
- SonarCloud getting started

### Phase 4: Deployment Automation (3-4 tuần)

**Mục tiêu**: Tự động deploy ứng dụng

**Học:**
- [ ] Deployment strategies (blue-green, canary)
- [ ] Environment management
- [ ] Secrets management
- [ ] Rollback strategies

**Thực hành:**
- [ ] Setup CD pipeline
- [ ] Deploy lên staging
- [ ] Deploy lên production (với approval)
- [ ] Health checks và rollback

**Tài liệu:**
- Deployment strategies
- GitHub Environments documentation

### Phase 5: Monitoring & Observability (2-3 tuần)

**Mục tiêu**: Setup monitoring và alerting

**Học:**
- [ ] Application logging
- [ ] Metrics collection
- [ ] Error tracking (Sentry)
- [ ] Alerting rules

**Thực hành:**
- [ ] Setup structured logging
- [ ] Setup Sentry cho error tracking
- [ ] Setup uptime monitoring
- [ ] Configure alerts

**Tài liệu:**
- Sentry documentation
- Prometheus documentation

### Phase 6: Advanced Topics (4-6 tuần)

**Mục tiêu**: Học các chủ đề nâng cao

**Học:**
- [ ] Infrastructure as Code (Terraform)
- [ ] Kubernetes basics
- [ ] Service Mesh
- [ ] Chaos Engineering
- [ ] Advanced CI/CD patterns

**Thực hành:**
- [ ] Define infrastructure với Terraform
- [ ] Deploy lên Kubernetes
- [ ] Setup service mesh

**Tài liệu:**
- Terraform documentation
- Kubernetes official docs

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

1. **Đọc kỹ guideline này** - Hiểu các concepts
2. **Chọn một area để bắt đầu** - Khuyến nghị: CI/CD
3. **Setup môi trường** - GitHub Actions đã sẵn sàng
4. **Thực hành với dự án hiện tại** - Bắt đầu từ đơn giản
5. **Học từ từ** - Đừng cố làm hết mọi thứ cùng lúc

**Remember**: Automation là một journey, không phải destination. Bắt đầu từ những gì bạn cần nhất!

