# v0.2.0 最终发布就绪报告

候选代码 077e40d84e68c9dac353fb80f49d90bf90680ae4 的本地和远程工程验收均通过。Windows Native 先前缺少 Runner 证据的阻塞已解除。发布准备文件已纳入本地冻结流程，最终提交仍须复跑远程 CI。正式发布和公开注册表安装等待授权。

| 验收项 | 证据 |
|---|---|
| 代码与兼容性 | 复核过预算和输入校验、候选缓存和分支，原接口及 JSON v1 保留，新增深度入口。 [独立审计](https://github.com/jojochensmart-lab/moonpicross/blob/077e40d84e68c9dac353fb80f49d90bf90680ae4/docs/V020_INDEPENDENT_AUDIT.md) |
| 平台 | Windows Native 构建成功并 18/18，Windows/Linux 的 JS 和 Wasm GC 各 18/18。 [候选 CI](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45604621651) |
| 算法与生成 | Oracle 15,745 组一致，每后端成功 1,449 个生成样本经独立验证。20×20 新组 168/200。 [生成报告](https://github.com/jojochensmart-lab/moonpicross/blob/077e40d84e68c9dac353fb80f49d90bf90680ae4/docs/V020_GENERATOR_STABILITY_REPORT.md) |
| Studio | Edge 真实磁盘导入、落盘、重导入、刷新与 20×20 测试通过。人工系统文件对话框待验证。 [Studio 验收](https://github.com/jojochensmart-lab/moonpicross/blob/077e40d84e68c9dac353fb80f49d90bf90680ae4/docs/V020_STUDIO_ACCEPTANCE_REPORT.md) |
| 包 | 本地原包及确定性源码 ZIP 均通过 CRC、清单和新的解包消费者。历史 Runner ZIP 未留档，完整历史字节比较尚不可做。 一致性审计见源码仓库的 docs/V020_ZIP_CONSISTENCY_AUDIT.md。 |

当前未推送 main、合并、打标签或发布。源码仓库含 docs/V020_FINAL_RELEASE_CHECKLIST.md。

## 最终冻结证据

本轮从 Git 最终提交的独立检出运行验收。最终 SHA、提交数、逐命令测试结果、两个 ZIP 哈希及清单在工作区 _build/v020-final-freeze/FINAL_FREEZE.md 和 SHA256SUMS 中。该记录在提交与打包完成后生成，以便引用实际受测的 SHA 及包哈希。历史 CI 链接只适用于上述候选 SHA。
