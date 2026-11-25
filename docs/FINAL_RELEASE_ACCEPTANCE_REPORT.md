# MoonPicross Studio v0.1.0 正式发布验收

**A. 全部完成，可以提交最终验收。** 发布和验收日期为 2026-11-25（北京时间）。验收范围为任务书列出的工程交付条款。

## 公开交付与版本

| 项目 | 实测结果 |
|---|---|
| GitHub 仓库 | Public，默认分支 main，公开 API 和文件验证通过。 [仓库](https://github.com/jojochensmart-lab/moonpicross) |
| 版本代码及提交历史 | v0.1.0 指向 2dc7550d90e6b5878ffb1500fffef4676e24969e。推送时比较了 13 个完整本地和远程提交 SHA，全部一致，原有 11 个提交全部保留。main 后续含安装说明和本报告。 [main 当前 HEAD](https://api.github.com/repos/jojochensmart-lab/moonpicross/commits/main) · [历史](https://github.com/jojochensmart-lab/moonpicross/commits/main/) |
| GitHub Actions | Linux、Windows 检查、构建、测试、示例和归档消费者均成功。 [发布代码运行](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45557919381) · [发布文档运行](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45560141581) |
| Pages | Actions 部署成功，公开首页、CSS、应用 JS、MoonBit 引擎均返回 HTTP 200。Edge 在部署地址运行完整网页探针。 [在线 Studio](https://jojochensmart-lab.github.io/moonpicross/) · [部署记录](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45558158096) |
| Release | v0.1.0，正式、非草稿、非预发行，公开请求 HTTP 200。离线 ZIP 校验后解包并通过 Edge 探针。 [Release](https://github.com/jojochensmart-lab/moonpicross/releases/tag/v0.1.0) · [离线 ZIP](https://github.com/jojochensmart-lab/moonpicross/releases/download/v0.1.0/moonpicross-studio-v0.1.0.zip) |
| Mooncakes | jojochensmart-lab/moonpicross@0.1.0。发布预检返回 202，正式发布返回 200。moon view 解析公开 0.1.0，网页返回 HTTP 200。 [模块页](https://mooncakes.io/docs/jojochensmart-lab/moonpicross) |
| 包来源 | Mooncakes 构建依据 f25dd187fc29e0df27960c36518f041258427ed7，与 Release 标签相比仅 README 不同。源码、版本、公开 API 相同。 [版本间差异](https://github.com/jojochensmart-lab/moonpicross/compare/v0.1.0...f25dd187fc29e0df27960c36518f041258427ed7) |

## 真实验证

| 检查项 | 结果 |
|---|---|
| 独立注册表安装 | 新临时项目无 moon.work 和本地覆盖。moon add jojochensmart-lab/moonpicross@0.1.0 明确下载 0.1.0，moon tree 确认注册表版本。moon check 通过，moon test 1/1，实际求解输出 Unique 和棋盘，生成示例再次证明唯一性并输出 v1 JSON。 |
| Windows Native | GitHub Windows Runner 执行 moon build --target native 和 moon test --target native，构建通过，10/10。开发机缺本地 C++ 编译环境。 |
| JS 和 Wasm GC | 本地每个后端 10/10。Wasm GC 检查、生成及构建成功，JS 桥接集成测试通过。原有 Wasm GC 的 26 条警告和 JS 桥接的 11 条警告均已修复。 |
| 独立 Oracle | Python 枚举与 MoonBit 对照 15,745 组棋盘线索、141 组行候选目录、510 个掩码，全部一致。 |
| 生成 | 5×5 为 100/100，10×10 为 100/100，15×15 为 94/100。每个尺寸使用 100 个固定种子，24 次尝试上限，所有成功样本再验唯一性。15×15 有 6 个尝试耗尽，全部候选中发生 56 次求解预算事件。 |
| 浏览器 | 实际在线和离线验证三态格、右键、线索与解、轨迹、种子生成、JSON 文件处理及导出 Blob、非法格式提示、15×15 窄屏横向滚动。 |
| 包与许可证 | 公共仓库、Release 离线包和 Core 归档均含 Apache-2.0 许可证。标准库是核心的唯一依赖，参考项目仅用于比较。 [许可证](../LICENSE) · [依赖与署名](OPEN_SOURCE_COMPLIANCE.md) |

命令复现和可选人工验证见 [测试说明](TESTING.md)。本地完整日志位于 _build/release-verification/，远程原始日志见上表运行链接。

## 三个场景

1. 开发者把行列线索传给 Puzzle::solve。独立注册表消费项目打印 Unique、菱形棋盘和推理指标。 [求解示例](../examples/solve)
2. 创作者固定种子生成谜题，重新求解确认唯一并输出题库 JSON。源码和注册表消费项目均实际运行。 [生成示例](../examples/generate)
3. 用户打开公网页面或解包后的 index.html 进行游玩和编辑。两种入口均在 Edge 实测，使用同一 JS 桥接的 MoonBit 核心。 [在线 Studio](https://jojochensmart-lab.github.io/moonpicross/)

## 章程交付项

| 条款 | 状态与证据 |
|---|---|
| MoonBit 为主要语言 | 达成。核心与公开 API 使用 MoonBit。GitHub 统计 MoonBit 79,770 字节，为首要语言。 [语言统计](https://api.github.com/repos/jojochensmart-lab/moonpicross/languages) |
| GitHub 公开且有效提交不少于 10 个 | 达成。公开 API 与原基线 11 个 SHA 核对一致。 |
| 源码和提交结构清晰 | 达成。核心、JS 桥接、Studio、测试和示例分目录，提交按实际开发任务形成。 |
| README 含定位、安装、用法与示例 | 达成。版本化安装、库调用、用例、演示和验证命令均可查阅。 [README](../README.md) |
| CI 有检查、构建和测试 | 达成。已查看 Linux 和 Windows 的成功运行，Windows 含 Native。 |
| 核心能力和测试 | 达成。作为本地源码及公开依赖均运行，另有独立穷举对照。 |
| 可运行示例与三个使用场景 | 达成。两个 CLI 示例、发布的在线和离线 Studio 均有运行证据。 |
| 发布到 Mooncakes | 达成。0.1.0 公开版本已从新项目下载和运行。 |
| OSI 认可许可及第三方合规 | 达成。Apache-2.0，第三方参考和 CI 组件有来源记录。 |

## 已知限制

首版聚焦 5×5 至 15×15。更大的棋盘属于探索范围，算法难度等级未经真人校准。浏览器自动验收验证了文件处理和导出内容，交互式系统文件对话框和实际下载落盘需人工操作。本地安装了 MoonBit 的 2026-10-28 构建，实际工具链不接受 moon.mod 的 homepage 键，因此网站地址由 README 和 Release 提供。发布初次 Pages 运行在站点还未启用时失败，启用 Actions 发布源后全流程通过。工程交付已验收，赛事表单仍由参赛者处理。
