# v0.2.0 发布审批材料

**B：核心功能通过，但跨平台发布包证据仍待归档。**

已验收冻结代码为 d13268237601f7ecde3ffffe145a21ed388bb5e2。历史 Windows Native、JS、Wasm GC 各 18/18，历史 Linux JS、Wasm GC 各 18/18。历史 Runner 归档的整体 SHA256、环境和 44 项清单见 [跨平台审计](V020_CROSS_PLATFORM_PACKAGE_AUDIT.md)。历史工作流没有上传 ZIP，尚无法证明跨平台逐文件相同。 [Windows 作业](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45611887770/job/139197256706) · [Linux 作业](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45611887770/job/139197257419)

本地新归档和对账流程验证通过。三个本地产物分别为 _build/v020-r16/final-local/ 下的 local-v020-release.zip、local-v020-source.zip、local-v020-studio.zip。manifest 和 SHA256SUMS 保存实际最终 SHA、工具链、每份 ZIP 和其成员哈希。本轮只有工作流、打包/测试工具及文档变更，原运行时代码和 v0.1.0 标签未改，未执行远程写入。

后续须单独授权推送新的候选分支，例如 codex/v020-package-evidence。随后等待 Windows-v020-release-evidence 和 Linux-v020-release-evidence 可下载，核对两端真实环境、SHA 和验收日志。下载后运行三方对账和各包的解包消费，核对规范化包的整体字节，保留每一项原始差异。只有完成上述工作并解释所有差异后，才建议进入正式发布审批。
