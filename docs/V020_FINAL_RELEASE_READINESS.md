# v0.2.0 最终发布就绪报告

**B：核心功能稳定，但仍有明确发布阻塞。** v0.2.0 完成独立本地验收。正式发布须取得候选版本 Windows Native 构建和测试的实际 Runner 结果。本轮没有远程写入。

| 验收项 | 实测 |
|---|---|
| 源码审计与修复 | 没有复现 P0/P1。修正预算与输入错误分类、导入后的线索状态及归档范围，并补浏览器回归。 [源码审计](V020_INDEPENDENT_AUDIT.md) |
| 算法、差分与资源 | JS、Wasm GC 各 18/18，原 Oracle 15,745 组与 141 组候选全部一致。独立 Python 参考器确认每后端 1,449 个成功生成条目唯一。预算、部分解与递归入口有专门检验。 [算法验证](V020_ALGORITHM_VERIFICATION.md) |
| 生成稳定性 | 原批次复现 200/200、200/200、200/200、84/100。新批次为 200/200、200/200、197/200、168/200。 [生成报告](V020_GENERATOR_STABILITY_REPORT.md) |
| Windows Runner | 本机没有可用 MSVC，Native 未通过本机编译计划。工作流配置已核对，托管 Runner 无本轮执行。 [CI 准备](V020_WINDOWS_CI_REPORT.md) |
| Studio 和文件 | Edge 操作、15×15 滚动和 20×20 基本操作通过。磁盘输入、导出落盘、读回、重新导入及刷新通过。Windows 选择对话框人工交互待确认。 [Studio 验收](V020_STUDIO_ACCEPTANCE_REPORT.md) |
| 包与消费 | ZIP CRC、清单、元数据、README、LICENSE 和敏感信息筛查通过。全新解包消费项目在 JS 和 Wasm GC 运行 JSON、唯一性、生成与 Budget 检查。v0.1.0 原公开接口保留，新增深度限制入口。 [发布包审计](V020_PACKAGE_AUDIT.md) |

待授权操作是将本轮候选 HEAD 推送至 codex/v020-windows-validation 分支并核对 CI 结果。v0.1.0 标签、历史 Release、已发布包和申报书保持原状。完整本地测试日志保存在 _build/v020-r14/。
