# MoonPicross Studio v0.2.0 最终发布清单

已验收候选为 077e40d84e68c9dac353fb80f49d90bf90680ae4。本轮只准备发布文档、打包工具和验收证据，运行时代码和 CI 配置与候选一致。

| 状态 | 项目 | 实测或限制 |
|---|---|---|
| PASS | Windows/Linux CI | Windows Native 构建成功并通过 18/18，两平台 JS 和 Wasm GC 也各 18/18。 [远程 CI](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45604621651) |
| PASS | Oracle 与生成 | 15,745 组一致。两个后端的 1,449 个成功种子样本分别重放并通过独立验证。 [生成报告](V020_GENERATOR_STABILITY_REPORT.md) |
| PASS | Edge 文件往返 | 实际选取磁盘文件、导出落盘并重新导入，同时验证 20×20 和刷新。系统文件对话框由 DevTools 驱动。 [Studio 报告](V020_STUDIO_ACCEPTANCE_REPORT.md) |
| PASS | 最终本地包与示例 | 两份 44 文件候选包通过 CRC、清单和敏感模式筛查，全新解包消费项目在 JS/Wasm GC 通过。格式、检查及三个源码示例通过。 |
| PASS | 本地确定性源码 ZIP | 三份同源码输入，以及时间、顺序、压缩、属性和行尾扰动，本地规范化输出分别字节一致。 [ZIP 审计](V020_ZIP_CONSISTENCY_AUDIT.md) |
| PASS | 文档、许可与申报事实 | 版本、安装边界、API、示例、许可证及数值均核对。 [内容审查](V020_RELEASE_CONTENT_REVIEW.md) |
| WARNING | 历史 ZIP 字节对账 | 日志可核对路径清单和整体 SHA256。原 Runner ZIP 未上传，无法逐文件对账或精确归因历史差异。 |
| WARNING | 跨 Runner 重现 | 新脚本在本地实测。最终发布 SHA 需复跑 CI 并保留原包。当前绿灯对应已验收候选提交。 |
| WARNING | 验收边界 | 20×20 生成仍是探索范围。难度未经真人校准，人工操作 Windows 系统对话框待验证。 |
| BLOCKED | 正式发布与公开安装 | 尚无本轮发布授权。注册表 0.2.0 的真实安装只能在发布后验证。本轮通过的是全新项目从解包候选消费。 |

可提交现有工程验收证据。授权后按 [发布手册](RELEASE.md) 复验最终 SHA 并实测公开安装。完整证据位于 _build/v020-release-evidence/。

## 本次冻结记录

此前各项 PASS 适用于注明的候选及准备阶段。最终提交的独立检出测试、实际 SHA、提交数、文件清单和 ZIP 哈希由 _build/v020-final-freeze/FINAL_FREEZE.md 与 SHA256SUMS 记录。候选 CI 通过不能替代最终提交的 Windows/Linux 验证。
