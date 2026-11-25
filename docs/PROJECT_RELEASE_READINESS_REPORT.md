# MoonPicross Studio 第二阶段发布就绪报告

本文件为发布前历史记录。最新结果见[正式发布验收](FINAL_RELEASE_ACCEPTANCE_REPORT.md)。

验收日期为 2026 年 11 月 25 日（北京时间）。模块为 jojochensmart-lab/moonpicross，版本 0.1.0。

**结论 B：核心功能完成，但还有少量发布阻塞。** JS 和 Wasm GC、离线 Edge、独立 Oracle 和本地包消费者均有实测证据。Windows Native、本批次精确日期、GitHub 公开验收及 Mooncakes 登记与安装仍待完成。首版范围是 5×5 至 15×15 黑白数织。

## 1. 项目完成情况

已把可行性原型推进为具有公共 API、示例、可离线交互界面、测试和本地发行包的项目。贡献及交付流程已落地。既有一期报告保留为历史证据。 [README](../README.md) · [开发记录](DEVELOPMENT_LOG.md)

## 2. 当前核心功能

core/model.mbt 定义三态格、谜题、输入错误及有界轨迹。core/solver.mbt 提供线索、候选、传播、搜索和生成入口。core/difficulty.mbt 提供生成配置和可解释的指标。JSON 版本 1 支持整数校验和语义校验。网页 JS 桥接与示例使用同一纯 MoonBit 核心。 [API](API.md)

## 3. 核心算法

对每条线枚举有限位掩码。传播过滤与已知格冲突的模式。候选交集确定必黑，候选并集的补集确定必白。传播停滞后，DFS 对首个未知格做两种赋值。到第二解即可证明多解，单解须穷尽剩余分支方可证明唯一。生成用种子采样棋盘、计算线索、重新求解并筛选。 [架构](ARCHITECTURE.md)

## 4. 唯一解验证

3×3 穷举 15,625 组线索，独立预期有 15,180 组无解、384 组唯一、61 组至少两解。4×4 和 5×5 各 60 组，每组尺寸是 15 无解、38 唯一、7 多解。已测试搜索只找到一个见证解即撞到预算时返回 Budget。

## 5. 谜题生成统计

种子 1–100，Wasm GC release，密度 45%，每种子最多 24 次，无难度过滤。成功样本再次运行 MoonBit 求解并由解重建线索。

| 尺寸 | 成功及复验数 | 失败数 | 预算耗尽候选次 | 平均、最长 ms | 平均节点/候选 |
|---|---:|---:|---:|---:|---:|
| 5×5 | 100/100 | 0 | 0 | 0.013、0.050 | 2.03 |
| 10×10 | 100/100 | 0 | 0 | 0.192、1.074 | 6.09 |
| 15×15 | 94/100 | 6 | 56 | 17.025、113.855 | 60.52 |

15×15 的 6 个失败为尝试次数耗尽。56 是所有种子合计中撞到求解预算的候选次数。详见 stage2-performance.log。 [资源与调查](RESOURCE_LIMITS.md)

## 6. 难度分析

唯一解的等级按节点数分为 Easy、Normal、Hard、Expert。记录初始候选数、最大候选域、传播轮数及每轮确定格数、节点、回溯和扫描。固定配置下计数可复现。浏览器和基准程序单独测时。5×5、10×10 和 15×15 的若干首批样本在一个节点内求解，探索性大棋盘出现多解和 Budget。等级用于估计当前算法工作量，人类难度尚无实证校准。

## 7. 资源预算

最大 30×30、候选 300,000、节点 5,000、扫描 5,000,000、深度 256、轨迹 2,000、解计数 2。测试覆盖异常尺寸、候选/节点/扫描额度、迹线截断和生成上限。大尺寸样本出现可解释的 Budget 或 AttemptLimit。核心调用可降低额度。没有测出可推广的 RSS 上限。 [资源细节](RESOURCE_LIMITS.md)

## 8. Windows Native

本机使用 MoonBit 0.1.20261028（e1e1f15）。moon build --target native 在构建计划、C 编译驱动检测处失败。cl.exe 或 clang-cl.exe 未被发现，未找到可供本次构建使用的 MSVC C++ 工具及 Windows SDK 组合。未安装系统软件，Native 测试未运行。原始错误在 native-stage2.log。Windows CI 已配置开发工具环境初始化，尚无远程实跑。

## 9. 浏览器与测试矩阵

| 命令 | 实际结果 |
|---|---|
| python tests/oracle.py | 生成独立用例，通过。现场使用可用的 Python 3 解释器。 |
| moon fmt --check | 通过。复验修正了重新生成夹具时的格式漂移，生成后校验无 diff。 |
| moon check --target wasm-gc | 通过，0 错误，现有工具链报 26 条弃用等警告。 |
| moon build --target wasm-gc | 通过。 |
| moon test --target wasm-gc | 10/10 通过。 |
| moon test --target js | 10/10 通过。 |
| moon run examples/solve --target wasm-gc | 通过，输出唯一解菱形和统计。 |
| moon run examples/generate --target wasm-gc | 通过，输出确定性的 JSON 并复验。 |
| node scripts/build-studio.mjs | 通过，生成本地 engine.js。 |
| node scripts/test-studio.mjs | 通过，包含结构化边界、求解、轨迹、线索和生成。 |
| pwsh -NoProfile -File scripts/test-studio-edge.ps1 | 通过，实际 Edge 加载 file URL，420×850。 |
| moon package --list 与 python tests/package_smoke.py | 通过，本地归档新消费者执行唯一解示例。 |

Edge 检查三态、右键白格、求解与轨迹、输入处理函数、真实 Blob 内容、非法版本、编辑提取、种子生成、15×15 窄屏滚动和重置。下载点击经拦截以核对 Blob 与文件名，系统文件选择器和实际写磁盘下载仍需人工验收。Wasm GC 在 CLI 通过，页面使用 JS 后端。

## 10. 独立 Oracle

tests/oracle.py 用直接枚举构造独立预期。测试对照 15,745 组棋盘线索组合，同时对长 1–8 的 510 个掩码按线索归组并对照 141 组完整候选域。生成调查中的成功样本复验使用同一 MoonBit 算法，独立枚举对照覆盖较小棋盘。 [复现说明](TESTING.md)

## 11. 三个完整场景

| 场景 | 输入与步骤 | 可验收输出 |
|---|---|---|
| 下游项目验题 | 提供菱形的行列提示，调用 Puzzle::solve | examples/solve 输出唯一、棋盘及统计 |
| 创作者生成题库样本 | 设尺寸、种子及次数，调用 GenerationConfig::run 后再求解 | examples/generate 输出可重放的 v1 JSON |
| 编辑者离线工作 | 打开 Studio、画图并提取线索、求解分析，再在浏览器交换文件 | 交互棋盘、步骤和 JSON。Edge 自动复验主要路径 |

## 12. GitHub CI

本地 Git 工作流覆盖 Linux/Windows、JS/Wasm GC、独立预期生成、格式、构建、测试、示例、离线浏览器探针、Windows Native 和归档消费者检查。正式远程地址、仓库可见性和 Actions 实跑均待用户审核后办理。本地 Git 日志属于开发证据；赛事要求的 GitHub 公开可见提交数仍待验证。

## 13. Mooncakes 安装验证

moon package --list 生成 _build/publish/jojochensmart-lab-moonpicross-0.1.0.zip。Python 校验 CRC 并解包到新的消费者工作区。消费者在自己的 moon.mod 声明版本化依赖，通过 moon.work 加载解包产物，导入 core 后运行例程。网站、桥接和开发脚本不随核心归档分发。对注册表模块做只读请求返回 HTTP 404。目前没有已登记模块或注册表安装的证据，归属和发布权限需由实际账号确认。

## 14. 许可证

Apache-2.0 已与本地包一起交付。核心依赖 MoonBit 标准库。独立 Oracle 生成用例，不附带参考项目源代码、关卡或美术。 [合规及参考清单](OPEN_SOURCE_COMPLIANCE.md)

## 15. 生态排重

同题型 MoonBit 项目 Picross Harbor 2026 的已查源码使用预置答案并从中求线索、给提示。MoonPicross 的通用输入、有界求解、唯一性和核心复用在已查同语言产品中未发现等价发布项。其他语言已有算法和产品先例。 [更新版排重](UPDATED_ECOSYSTEM_AUDIT.md)

## 16. 赛事要求

十一月报名活动在 MoonBit 中文官网可见。适用章程原件、十一月精确报名截止及最终验收日期待证实。10 个有效 GitHub commits、公开仓库和 Mooncakes 发布还依赖后续公开验证。人工申报材料只准备了事实底稿。 [赛事逐条核对](COMPETITION_REQUIREMENTS.md) · [事实底稿](APPLICATION_FACTS.md)

## 17. 已解决问题

核心 API 统一了输入和预算错误。额外测试发现并修复了 JSON 小数被当成整数、JS 解网格形状不匹配、重新生成夹具后格式漂移。离线浏览器、归档下游运行及 300 种子实测均已取得可复查结果。

## 18. 未解决问题

Windows Native 和 GitHub Actions 尚缺实际验收。Mooncakes 账号归属、登记、注册表新项目安装、仓库地址、批次日期仍待核实。15×15 已观察到失败，20×20 与 30×30 属于探索。自动 Edge 探针未经过系统文件对话框，未建立发布级加载延迟和内存峰值量化基线。

## 19. 正式发布步骤

确认批次和发布身份。补齐 Native 环境证据。审批后使用正确仓库地址公开提交并检查 CI。核准命名空间，获得专门发布许可后办理 Mooncakes 发布并从注册表建立新的独立消费者。以可访问 URL 与实际命令输出核对发布。 [发布清单](RELEASE.md)

## 20. 待用户审核与授权

请在方便时提供本批次章程或最新官方群公告，确认 GitHub 正式地址和 Mooncakes 命名空间的实际归属。Native 可在具备工具链的环境验收，如需本机系统级工具安装应单独审核。公开仓库、推送、正式发布和报名等待各自授权。MoonAvro 工作区未参与本次开发。
