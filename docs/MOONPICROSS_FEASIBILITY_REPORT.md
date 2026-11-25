# MoonPicross Studio 立项前可行性与发布预检

日期 2026-11-25（北京时间）。**结论 B：核心算法与离线浏览器工作路径已验证，正式立项仍要补原生后端、注册表权限和赛事原文证据。** 当前应保留候选项目，立项主题聚焦可验证的 MoonBit 数织工具链。

## 1. 项目定位

Core 为纯 MoonBit 数织线索、求解、第二解截止及种子生成库。Studio 使用同一库在浏览器运行。计划提供编辑、推理回放和本地文件，当前仅有 5×5 技术原型。

## 2. GitHub 生态排重

未确认已公开的同定位 MoonBit 模块。发现 MoonBit 同题型游戏 Picross Harbor 2026，基于 12 个预存解及提示。其他多种语言已有生成器、求解、第二解与解释界面，赛事价值应限定到 MoonBit 工具链、可复现验证及资源边界。 [排重报告](ECOSYSTEM_DUPLICATION_AUDIT.md)

## 3. Mooncakes 生态排重

检索 nonogram、picross、griddlers、hanjie 与 puzzle solver。bobzhang/games@0.9.33 的 Picross Harbor 子包是直接的游玩场景对照。MoonPeg 是其他题型可复用经验。

## 4. 同类方案

候选枚举、约束传播、DFS、固定种子生成和浏览器操作已有先例。此原型的价值在于连接三项能力：通用线索输入、独立验证与离线共享引擎。逐条产品差异与许可证记录在排重报告。

## 5. 核心设计

以 30 位以内整数掩码表示行列。线索后缀占用量约束每组起点，组间最少一格。传播按回合先行后列，筛去与已知黑白冲突的掩码。幸存候选按位 AND 决定必黑，OR 的补集决定必白；因此所有推导均被当前一致的行或列候选支持。无候选即矛盾，一个回合零新增格则进入 DFS。DFS 对首个未知格试 0/1，找到两个不同完整赋值即报告 Multiple。穷尽后才报告 Unique 或 NoSolution。预算耗尽返回 Budget，即使此前找到一个解。

## 6. 原型结构

core/solver.mbt 实现候选、传播、DFS、种子生成和指标；core/solver_test.mbt 固定回归；tests/oracle.py 产生 core/oracle_test.mbt；demo/main.mbt 是 CLI 验证和计时入口；webapi/export.mbt 提供 JS 边界；studio/index.html、app.js、engine.js 构成静态演示。源码在独立 D 盘目录，MoonAvro 未被修改。

## 7. 独立 Oracle

Python 使用 itertools.product 暴力枚举并从黑白字符串计连续段。对 3×3 用 512 个二值图样形成解计数，再检查 5^6 = **15,625** 个行列线索组合。0/1/至少2 解分别为 **15,180 / 384 / 61**，全部一致。4×4、5×5 各 60 个用例，每尺寸 15 无解、38 唯一、7 多解。Python 先枚举单行实际图样，再做笛卡尔积检验列，不依赖 MoonBit 的传播和 DFS。样本种子 20261125，五组密度 15/35/50/65/85%，含刻意不一致的列。总计 **15,745 组独立对照**。

## 8. 唯一性边界

固定测试覆盖空线索、单段、大段、多段 [3,2]（长10共15种）、满行、非法线索、30/31 尺寸与候选上限。2×2 每条线索 [1] 多解，设置 2 个 DFS 节点仅找到一个解后即返回 Budget。资源耗尽路径也覆盖扫描额度为零。算法计数仅区分 0/1/≥2。

## 9. 生成实测

种子 1、7、99，密度 45%，每种尺寸与种子最多 12 次。xorshift32 生成图样，提取线索；Multiple 或 Budget 跳过，无解/非法返回内部异常，只有 Unique 接受。固定测试重复种子 7 核对图样、尝试计数、求解值和重新提取线索。

| 尺寸 | 成功数 | 成功尝试次数 | 整组单次生成时间范围（含失败） |
|---|---:|---|---|
| 5×5 | 3/3 | 1,1,1 | 约 0.014–0.043 ms |
| 10×10 | 3/3 | 1,10,4 | 约 0.060–1.460 ms |
| 15×15 | 3/3 | 1,9,2 | 约 0.344–29.458 ms |
| 20×20 | 2/3 | 2,失败,7 | 约 5.55–94.03 ms |
| 30×30 | 0/3 | 均 AttemptLimit | 约 62.59–71.45 ms |

小样本仅支持“这些固定样本可复现”，不能称 15×15 广泛稳定。建议首版以 5–15 为目标，20 探索，30 明确实验性。

## 10. 性能、指标及资源预算

Windows，MoonBit 0.1.20261028（e1e1f15），命令 moon run demo --target wasm-gc --release。下表为 CLI 中另一确定性图案、单次求解，计时源为 MoonBit monotonic_clock（微秒转换为毫秒），未测可靠 RSS。原始数据在 performance.log。

| 尺寸 | 状态 | 累计候选 / 最大域 | 轮数 / DFS节点 / 无产出分支回溯 | 扫描次数 | ms |
|---|---|---|---|---:|---:|
| 5 | Multiple | 38 / 6 | 9 / 3 / 0 | 342 | 0.319 |
| 10 | Multiple | 439 / 36 | 12 / 3 / 0 | 5268 | 0.088 |
| 15 | Multiple | 4162 / 462 | 28 / 9 / 0 | 116536 | 1.297 |
| 20 | Multiple | 41412 / 5005 | 78 / 24 / 16 | 3003752 | 5.817 |
| 30 | Budget | 290942 / 92378（完成的行域） | 0 / 0 / 0 | 0 | 5.733 |

最大 30×30（900 格），原型默认 300,000 个候选、5,000 DFS 节点、5,000,000 次候选扫描，DFS 深度不超过 256，演示尝试上限 12，API 参数最多 1000 次。组合枚举和 DFS 最坏指数增长。指标记录每轮确定格数及各项计数；时钟只作性能观察。推荐以“一次传播搜索节点 / 发生分支 / 预算未完成”表示算法复杂度等级，指标说明具体原因，不给主观加权分，也不推断人的难度。原型日志暂不保存每一格原因及推理证书。

## 11. 浏览器与后端

moon build webapi --target js --release 将 MoonBit 编译成 IIFE，公开 solve_demo，返回状态与 25 格编码。构建产物复制到 studio/engine.js。Edge 126.0.2592.61 headless 直接 file:// 加载，检测点击可切换、显示线索、调用 MoonBit、渲染 Unique 和 13 个黑格，DOM 标记 data-probe=passed。无后端或网络依赖。Wasm GC 在 CLI 测试通过，浏览器采用已复验的 JS 路线；未验证浏览器 Wasm ABI。原生目标因当前 Windows 缺 MSVC C++ 工具链和 SDK 未能构建。在 Wasm GC 默认目标运行 moon check，测试 5/5；moon test --target js 5/5。 [MoonBit JS 导出配置](https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html)

## 12. Mooncakes 本地预检

实际 GitHub Owner 为 jojochensmart-lab，候选 jojochensmart-lab/moonpicross@0.1.0 格式符合 owner/module + SemVer。公开 moon view 返回 manifest HTTP 404，表示未查到可见包，不能确认可注册或实际账号权限。当前未验证 Mooncakes 身份或命名空间所有权，正式发布需用户在其账户中确认；本地打包没有认证依赖。moon package --list 返回成功，生成 13,348 字节 ZIP，内含 Core、CLI、Oracle、README 和 LICENSE，排除 Studio、报告、日志及竞品证据。README、SPDX、描述、关键词和版本已填。真实 repository URL 待建仓。无外部 MoonBit 依赖。 [官方发布指南](https://docs.moonbitlang.com/en/stable/toolchain/moon/package-manage-tour.html)

## 13. GitHub 条件

gh api user 核实账户 jojochensmart-lab。读取该账户目标 repo 返回 404，仓库名搜索未查到 moonpicross；可见性尚无现成仓库可验证，也未实际试写权限。GitHub Pages 可发布 HTML/CSS/JS，适合此静态结构。CI 可用 moon check、moon test、Python oracle 再生和 JS 构建作为初始任务；远程 CI 与 Pages 未验证。 [GitHub Pages 文档](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages)

## 14. 许可证与数据

原型使用 Apache-2.0 正式文本。算法按标准数织约束独立编写，未将参考项目或 MoonAvro 源码带入。Oracle 与棋盘由本地穷举/伪随机生成。标准库随工具链；Python 与浏览器只用于验证。未确认许可的参考仓库仅供调查，不复制代码资源。名称 Picross 用于题型说明，发布前可用 Nonogram 主标题减少与既有品牌混淆。

## 15. 赛事章程

附件只有任务说明，当前工作区、附件目录及可访问的常见文档目录未找到用户提供的章程原文。MoonBit 语言、GitHub、提交数、README、CI、示例、测试、Mooncakes、许可证、三场景、申报与最终验收日期和奖励条件全部待原文核对。本地技术通过、成功上架、满足申报和通过最终验收是四个分别需要证据的状态。请提供章程原文或路径。

## 16. 未解决事项

Windows 原生工具链、Mooncakes 账户权限、远程 CI、章程均待核验。大尺寸候选爆炸可用更紧预算、行 DP 及更优分支策略研究，暂定非首版承诺。交互式编辑、JSON 文件、逐步推理细节、强度分布测试和明确的公共输入校验待正式开发。独立 5×5 以上大样本唯一性覆盖仍需扩大。

## 17. 工作量与发布路线

以下为单人估算，依赖章程与权限确认，并非赛事日期承诺。

1. 核心算法 2–4 工作日，冻结 API、三场景（手工线索验证、种子生成、批量难度统计）和错误语义。
2. 浏览器 2–4 日，补编辑、文件导入导出、回放及可访问性。
3. 全面测试与 CI 2–3 日，扩大样本、补原生与浏览器、重复计时。
4. GitHub 公开 0.5–1 日，获授权后建仓、验 CI 与 Pages。
5. Mooncakes 0.5–1 日，确认命名空间和权限，再验证下游安装。
6. 赛事材料与验收 1–2 日，按原文整理版本、测试和三个完整场景。合计约 8–15 工作日，审批等待另计。

## 18. 最终建议

**B. 核心算法可行，但浏览器或发布环节需要修复。** 离线浏览器链路已通过，B 的决定性因素是原生验证、远程发布资格及章程未齐。独立价值足以保留候选，当前不宜以“首个 MoonBit 数织游戏”或“原创求解算法”申报。此轮没有创建远程仓库、推送、占名或发布包。
