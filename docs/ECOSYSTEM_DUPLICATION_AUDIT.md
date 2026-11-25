# MoonPicross 生态排重

审查日 2026-11-25（北京时间）。公开范围覆盖 GitHub 仓库、Mooncakes 模块及其子包、MoonBit 文档和 Community。搜索组合包括 Nonogram、Picross、Griddlers、Hanjie、picture logic puzzle、puzzle solver、constraint solver、puzzle generator，以及 Nonogram solver、Picross generator、uniqueness 和 difficulty analysis。GitHub 的 MoonBit 语言过滤未返回数织项目，但 Mooncakes 的说明搜索找到大型合集中的单个游戏，说明只查仓库名和语言会漏报。结合 GitHub API 核对 README、目录和算法关键源码。日期用 GitHub pushed_at（UTC），不等同于每个子项目自身的最后提交。不宣称穷尽未索引项目。 [MoonBit Community](https://moonbit.community/) · [MoonBit 官方更新](https://www.moonbitlang.com/updates)

分类：A 为同语言且产品目标相同；B 为同语言相邻项目；C 为其他语言同类项目；D 为仅技术思路相邻的项目。本次在上述范围内未确认 A 类；确认一项高度相关的 B 类数织产品，以及多个 C 类直接功能参照。

| 项目 | 语言、最近推送 UTC、许可证 | 源码与完成度 | 重叠及分类 |
|---|---|---|---|
| Picross Harbor 2026 | MoonBit/raylib，父仓库 2026-11-13，子项目许可证未确认 | internal/game/logic.mbt 的 apply_level_rows、compute_all_clues 和 use_hint 依据预存解；load_level 提供 12 关。该子包树未见独立测试文件。 | **B，同题型游玩竞品**。线索、手工关卡、游玩与提示重叠；所查代码未见面向任意线索的约束求解、唯一性认证或随机生成。 [源码](https://github.com/bobzhang/games/blob/main/picross_harbor_2026/internal/game/logic.mbt) · [Mooncakes](https://mooncakes.io/docs/bobzhang/games/picross_harbor_2026) |
| ljiang9/nonogram | Python，2026-10-06，MIT | nonogram.py 的 line_placements、solve、propagate 构成行列逻辑和回溯；generate 镜像采样；main 提供 CLI 和文本保存。生成函数直接返回图样，未在该函数内检查第二个解。仓库树未见自动测试目录。 | **C，算法和 CLI 高重叠**。生成、传播、回溯均为已有功能。 [源码](https://github.com/ljiang9/nonogram/blob/main/nonogram.py) |
| monkeyArms/nonogram | JavaScript，2023-01-04，MIT | src/solver.js 维护位置候选、交集、逐格日志、求解结果；README 提供创建和游玩。未确认生成器做唯一性认证，仓库树未见命名测试。 | **C**，浏览器玩法与推理日志相近。 [源码](https://github.com/monkeyArms/nonogram/blob/master/src/solver.js) |
| simon-frankau/nonogram-solver | Rust，2021-08-14，MIT | src/main.rs 的 expand、constrain_poss、constrain_known、solve_recursive 使用位图、约束和递归，可枚举所有解；tests/solver.rs 及内联用例覆盖无解、多解。未见谜题生成入口。 | **C**，位图和唯一性基础非新颖。 [源码](https://github.com/simon-frankau/nonogram-solver/blob/main/src/main.rs) |
| cgissing/Nonogram-Solver | Python，2026-03-07，许可未确认 | nonogram/solver.py 有行候选、propagate/propagate_once 和 DFS；Tkinter 支持编辑及 JSON。未确认生成器和自动测试。 | **C**，编辑与求解产品同类。 [源码](https://github.com/cgissing/Nonogram-Solver/blob/main/nonogram/solver.py) |
| timonkobusch/nonogram | TypeScript，2025-07-30，MIT | src/modules/NonogramHumanSolver.ts 枚举行并作人类式传播；有 Nonogram 与 HumanSolver 两类 spec。生成可逻辑求解的谜题，完整第二解穷举未确认。 | **C**，浏览器生成、难度/人类式解题高度相关。 [项目](https://github.com/timonkobusch/nonogram) |
| jayzba/Nonogram-Solver | JavaScript，2026-09-26，许可未确认 | generator.js 采样后提取线索；solver.js 枚举合法排列、传播及回溯演示。生成路径未见唯一性认证，未见命名测试。 | **C，与 Studio 产品功能高度重叠**。 [生成器](https://github.com/jayzba/Nonogram-Solver/blob/main/generator.js) · [求解器](https://github.com/jayzba/Nonogram-Solver/blob/main/solver.js) |
| hyjump/Nonogram-Solver | Python，2026-01-03，许可未确认 | nonogram/solver.py 的候选、传播和 DFS，Tkinter、JSON；README 宣称多解检测。未单独确认生成或自动测试。 | **C**，本地工具功能重叠。 [源码](https://github.com/hyjump/Nonogram-Solver/blob/main/nonogram/solver.py) |
| kekeshuo/moonpeg | MoonBit，2026-09-11，MIT | peg solitaire 的有界搜索、逆向生成和可回放证书；board_test、boundaries_test、generate_test 等。棋盘是跳棋占用状态。 | **D**，借鉴预算结果、重放与边界测试设计，谜题对象及约束不同。 [项目](https://github.com/kekeshuo/moonpeg) |

未运行参考项目的全部测试。“未确认”保留为证据边界。MoonBit 生态的可辩护增量是可安装的通用数织核心、第二解截止和预算失败语义、可复现的检查证据，以及浏览器复用同一求解器。逐步解释、唯一性和浏览器玩法在其他语言生态已有先例，不能单项包装为原创算法。 [公开的浏览器第二解与推理回放工具](https://chaoschemy.com/tools/nonogram-solver/)
