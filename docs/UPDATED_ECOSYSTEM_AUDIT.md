# MoonBit 生态独立性复查

2026-11-25 复查。GitHub 仓库索引查询 nonogram moonbit、picross moonbit 两组均返回空列表。Mooncakes 的 moon search nonogram 返回 bobzhang/games@0.9.33，其中有 picross_harbor_2026 子包。既有审计另外检索 Griddlers、Hanjie、puzzle solver 和相关组合。检索受索引、包说明和子包可见度影响。 [前次审计与其他语言案例](ECOSYSTEM_DUPLICATION_AUDIT.md)

## Picross Harbor 2026 源码

GitHub 路径提交查询返回 4062e5176f2d281a385cf5be35c177f4fe83c0e7，提交时间为 2026-11-13 04:18:29 UTC。 [固定源码](https://github.com/bobzhang/games/blob/4062e5176f2d281a385cf5be35c177f4fe83c0e7/picross_harbor_2026/internal/game/logic.mbt) · [Mooncakes 子包](https://mooncakes.io/docs/bobzhang/games/picross_harbor_2026)

| 检查项 | 源码判断 |
|---|---|
| 谜题表示和预置答案 | 存在内部棋盘表示。load_level 选择 12 组预置关卡，apply_level_rows 载入解。 |
| 线索与提示 | compute_all_clues 从已知解算线索。use_hint 通过 solution_at 查预载答案。 |
| 任意谜题输入 | 所查路径未见公开任意线索输入接口。 |
| 独立求解及唯一性 | 所查路径未见约束求解器或第二解检查。 |
| 通用生成器 | 所查路径未见随机候选构造加唯一性认证的入口。 |
| 预算和难度 | 所查路径未见可配置求解预算或独立难度分析报告。 |
| 可复用 API | 游戏内部类型与交互存在。所查公开接口未见供调用者独立运行的数织引擎。 |

moonpeg 提供其他题型的预算、生成与证书对照。Python、JavaScript 与 Rust 已有数织传播、搜索、生成及交互实现。MoonPicross 的增量集中在 MoonBit 原生复用、输入及资源契约、生成后的完整唯一性认证、独立穷举验证和同核离线使用。当前未确认应触发停止开发的成熟同定位 MoonBit 项目。 [moonpeg](https://github.com/kekeshuo/moonpeg)
