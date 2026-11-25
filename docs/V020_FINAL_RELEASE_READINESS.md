# v0.2.0 最终发布就绪报告

**冻结提交的 Windows/Linux CI 已通过。** 最终候选为 `d13268237601f7ecde3ffffe145a21ed388bb5e2`。该 SHA 来自指定候选分支的 push 事件，已核对远程分支与运行元数据。 [候选分支](https://github.com/jojochensmart-lab/moonpicross/tree/codex/v020-final-release-validation) · [完整运行](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45611887770)

| 验证项 | Windows | Linux |
|---|---|---|
| MoonBit 工具链 | 0.1.20261119（738607b） | 0.1.20261119（738607b） |
| 格式、检查、Wasm GC 构建 | 通过 | 通过 |
| Native | MSVC 环境初始化、构建成功，18/18 | 工作流无此目标 |
| JS / Wasm GC | 各 18/18 | 各 18/18 |
| 例程、独立 Oracle、生成证书 | 通过 | 通过 |
| Studio | JS 桥接、Edge 离线与磁盘文件往返通过 | JS 桥接通过 |
| Moon 包与解包消费 | 44 项，通过 CRC、清单和双后端消费 | 44 项，通过 CRC、清单和双后端消费 |

[Windows Runner](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45611887770/job/139197256706) · [Linux Runner](https://github.com/jojochensmart-lab/moonpicross/actions/runs/45611887770/job/139197257419)

## ZIP 对账

| 来源 | 整体 SHA256 |
|---|---|
| 本地 MoonBit 原包 | aff5c83bd7fd7353ef5cc2e470ff12ef1d982997d5dbb271718b93a068ec4f35 |
| 本地规范化源码包 | 73b6607973797d29497d92695851899a0afad4125207c022c81bb6d26f49272c |
| Windows Runner MoonBit 原包 | 9541f21c52b6b2cc51464f4f1ba9b4a4edd1c095fba00d04b7c2c0a90573a069 |
| Linux Runner MoonBit 原包 | 1874e84107c5cd96c7830aa0c793fd7bdf916ec8d817762e341c93eb37f26496 |

两个 Runner 日志中的 44 个成员名称均与本地原包和规范化包一致。两台 Runner 的包自检均通过。该脚本校验 CRC，检查模块名、版本、许可证和仓库元数据，将 README、LICENSE 和 moon.mod 与各自检出逐字节核对，并在解包后的独立项目运行 JSON、求解、唯一性、生成和预算检查。两份 Runner 原包的整体 SHA256 各不相同，也均不同于本地两包，因而已确认原始 ZIP 字节不一致。

Actions API 显示本次运行有 0 个可下载产物。Runner 没有提供原包或逐成员哈希，无法独立比对跨平台文件内容、成员 SHA256 或 CRC 值。没有在 Runner 上实测规范化 ZIP 的字节级一致性。本地规范化包已验证重复构建字节一致。

## 证据与发布建议

完整日志、步骤结论、包清单和引用状态保存于 _build/v020-final-ci-45611887770，包括 windows-full.log、linux-full.log、windows-key.log、linux-key.log、run.json、artifacts.json、package-comparison.json 和 refs.json。

本地 main 仍停在冻结 SHA，远程 main 仍为 253a51b9d47657b5560e1b1be6f4a4e69c0b17f6。v0.1.0 标签仍为 2dc7550d90e6b5878ffb1500fffef4676e24969e，旧 Release 的离线附件摘要仍为 cfb8b30bfeb649dbc573f45d00f6bdd5a14716928dfee4ef3176c4abb8335e4a。本轮只推送候选分支。本报告仅本地更新。

**建议进入正式发布审批。** 工程验收通过。若要求跨平台 ZIP 内容一致性作为发布门槛，须在另行授权后留存两端原包或逐成员 SHA256，再做对账。发布授权、发布操作和 Mooncakes 0.2.0 公开安装验收仍是独立步骤。

第十六轮增加了跨平台逐文件一致性的审批条件，结论更新为 B。旧 CI 仍是冻结候选的有效功能证据。新产物归档和三端对账待授权运行，详见源码仓库中的 docs/V020_FINAL_APPROVAL_REPORT.md。
