# 五子棋项目设计文档

> 我将我的c++课程设计项目（项目名称：五子棋）授权给（C++程序设计基础）MOOC教学团队使用，允许其在互联网以及所需要的教学中传播、宣传和展示。

## 项目成员

- 倪子奕: 实现跨平台的终端控制库和设计平局判定算法，并编写相关文档。
- 周鋆山: 用户界面交互逻辑、编写用户命令解析程序，测试完成的游戏，编写相关文档。
- 何佳奕: 设计并编写 gb\_game 的内存结构以及部分游戏操作和终局判定算法。

## 运行环境

本项目可在 Windows 环境、支持 POSIX 操作系统接口和 ANSI 终端控制符的操作系统（如多种 Linux、BSD 发行版）上使用较高级的用户界面，获得较好的用户体验。

也可以在只支持 ANSI C 的机器上正常游玩。

## 项目总体框架

项目划分三个部分，分别是

- 使用标准 C++ 编写的 gb\_game 类及其相关函数。用来处理游戏相关逻辑和数据。（gb\_ 开头的所有函数）
- 跨平台的 tm 相关函数，用于控制终端。（tm\_ 开头的所有函数）
- 使用 gb\_game 和 tm 两个部分提供的接口，构造用户交互界面。（其他函数）

## 项目设计思路

### 对跨平台终端控制库的设计（倪子奕）

何佳奕在实现五子棋库后为了向演示库的使用方法，写了个小小的 demo 程序。但是由于他的程序在控制终端时使用了某种转义控制符，程序在 Windows 的命令提示符下会跑出乱码。同时，周鋆山实现的的界面程序在他的环境下无法编译通过。这妨碍了组员之间的合作。

同时，我们觉得实现对多种操作系统的支持是有意义的，这可以使我们明白哪些函数是 C++ 的标准库，哪些则是平台相关函数。

所以我阅读了两份程序的代码，发现两个程序都用到了同样的两种抽象，分别是清空屏幕和无缓冲地读取一个字符。这启发我做一个中间层，来消除平台的区别，为用户界面提供统一的抽象。

最开始的时候我们决定为上文两种环境分别实现两个函数，用来提供清空屏幕和读取字符的抽象。但是经过反复讨论与研究，综合多种考虑，我们决定在三个环境实现三个函数：tm\_getch、tm\_set、tm\_clear，也就是最终代码里的函数。

### 对用户交互界面的设计（周鋆山）

我最开始的时候想设计一个让玩家输入坐标来下棋的界面，但是玩了两下发现完全不好玩。要找到准确的坐标几乎要拿尺子把长度量出来。

后来经过多次尝试，我想出了这种用键盘移动光标来下棋的方式。这样比较符合直觉，玩起来也比较方便。只是这样的界面比单纯的输入坐标再来下棋的界面要难做一些，最后写了很长的用户输入处理程序。

我觉得在下侧提供按键提示的功能非常好玩，非常直观。

倪子奕提供的终端控制函数非常好用，写程序时节省了许多时间。

### 对五子棋游戏的设计（何佳奕）

感觉五子棋实现的难度不算特别大。按照游戏规则写，再向周鋆山提供接口就行了。

因为设计了独特的内存使用方式，所以内存管理也没有难度。

最难的部分应该是判定胜利或平局。重复写了若干次。感谢周鋆山同学耐心的测试。

设计的时候想着让库的使用尽量灵活一些，所以对棋盘的大小、获胜所需连子数量、玩家数量都没有做出限制。也就是说，如果建立一个 3x3 的棋盘并且把 num\_to\_win 设置成 3，就可以下井字棋；如果把 num\_player 设置成 5，就可以 5 个人一起下棋……当然我没试过。

不过好像成品的用户交互界面的时候没有体现这个神奇的功能。想要修改上面那两个变量还是得修改源代码，有点遗憾。

## 项目完成中遇到的问题及解决过程

### 跨平台终端控制（倪子奕）

#### 完全没用过 Linux

简单学习了一下 Linux 下的终端控制机制，参考了 busybox、musl 等多个开源项目的文档与多个博客，最终实现了可能不是最佳但是能够完成预期行为的函数。

#### 如果要实现跨平台，就要手动确定相关函数实现，并且复制到程序中

使用条件编译检测编译环境，解决了这个问题。代码里存在针对三个平台的函数，但是实际编译的时候只有一组会被编译。

#### 清理屏幕过慢，造成屏幕闪烁

研究后发现是终端本身速度较慢引起的。所以应该减少对终端的操作次数。注意到周鋆山的交互界面每次都会重绘整个页面，这样 tm\_clear 的清屏变成了无效操作。所以引入了 tm\_set，仅仅将光标移动到左上角，接着新输出的界面会覆盖上一次的，在效果不变的情况下减少了大量终端操作，提高了效率。tm\_clear 仅在棋盘大小发生变化时调用。所以 tm\_set 是为了效率而额外引入的一个函数，并不在初始的设计之中。

### 用户交互界面（周鋆山）

#### 输入坐标的交互界面过于难玩

发现输入坐标因为估计错误，总是下歪。提供的五子棋库又没有悔棋机制，玩得比较烦。后来研究了一下网页上的五子棋小游戏，发现别人用的是鼠标控制。考虑终端程序没有鼠标，所以照搬肯定是不行的。仔细地想了想怎么在终端做出类似鼠标的功能，想到了在屏幕上显示一个独特的字符当做 “光标”，再用按键去移动它。经过反复修改修改成了现在的用 “<>” 标记当前位置样子。

#### 屏幕经常闪烁

与提供终端控制函数的倪子奕讨论后找到了问题，用新引入的高效的 tm\_set 函数改写了部分代码，提高了效率。

### 五子棋游戏（何佳奕）

#### 判断某位玩家是否胜利

这一部分是比较让人头疼的一部分，改了很多次，但是总被周鋆山发现问题。最后留下的基本正确的实现也有很多冗余的计算，如果想利用这个库写什么蒙特卡罗搜索树之类的暴力下棋算法估计还需要多多优化（不过好消息是这个库可以直接用在多线程程序里 :-)）。

现在的判定方法是这样的：枚举边界上的每一个点，对于某一位玩家，检查其周围八个方向上是否有足够的连续自己的棋子。如果有就判胜，否则检查下一位玩家。所有点和玩家检查完毕后，检查是否为平局。

# 五子棋项目代码实现

```cpp
#if 0
name="a"
gcc -Wall -Werror -Wshadow -fsanitize=address -O0 -g "$name".c -o /tmp/"$name"-$$ || exit 1
/tmp/"$name"-$$ "$@"
ret=$?
rm /tmp/"$name"-$$
exit $ret
#endif

/* 以上是某种神秘的 magic header，用于让该文件在安装了编译器和 posix shell 的环境下
 * 能够当作脚本文件直接执行，可减少键盘敲击次数，防止手指磨损。
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

/* 从这儿到 #endif 都是平台 UI 相关实现，因为写项目时尚未学习类相关知识，
 * 所以并没有实现专门的 tm 类，所有相关函数以 tm 开头。
 */

#if defined(_WIN32)

#include <windows.h>

/**
 * tm_getch() - 无缓冲地从标准输入读取一个字节
 *
 * Return: 一个有符号整数，为读取到的字节
 */
int tm_getch(void)
{
	return getch();
}


/**
 * tm_set() - 将光标放置在终端 (0, 0) 的位置
*/
void tm_set(void)
{
	COORD pos = { 0, 0 };
	HANDLE output = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleCursorPosition(output, pos);
}

/**
 * tm_clear() - 清空当前终端屏幕
 */
void tm_clear(void)
{
	system("cls");
}

#elif defined(_POSIX_C_SOURCE)

#include <unistd.h>
#include <termios.h>

int tm_getch(void)
{
	struct termios tm, tm_old;
	int fd = 0, ch;

	if (tcgetattr(fd, &tm) < 0)
		return -1;
	tm_old = tm;

	/* 更改终端为 raw mode */

	/* 我们发现 cfmakeraw 是 BSD 实现的扩展，并不在 POSIX 标准中，所以
	 * 我们自行实现了一个 */
	/* cfmakeraw */
	tm.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON);
	tm.c_oflag &= ~OPOST;
	tm.c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN);
	tm.c_cflag &= ~(CSIZE|PARENB);
	tm.c_cflag |= CS8;
	tm.c_cc[VMIN] = 1;
	tm.c_cc[VTIME] = 0;

	if (tcsetattr(fd, TCSANOW, &tm) < 0)
		return -1;

	ch = getchar();

	/* 恢复终端设置 */
	if (tcsetattr(fd, TCSANOW, &tm_old) < 0)
		return -1;

	return ch;
}

void tm_set(void)
{
	printf("\033[0;0H");
	fflush(stdout);
}

void tm_clear(void)
{
	printf("\033[H\033[J");
	fflush(stdout);
}

#else

int tm_getch(void)
{
	return getchar();
}

void tm_set(void)
{
	putchar('\n');
	fflush(stdout);
}

void tm_clear(void)
{
	putchar('\n');
	fflush(stdout);
}

#endif

/**
 * struct gb_game - 存储五子棋（gobang）游戏相关信息
 * @mem: 棋盘和指针数组所占用的内存
 * @board: 棋盘，指针数组是为了方便访问 @mem 元素而建立
 * @width: 棋盘宽度
 * @height: 棋盘高度
 * @turn: 当前下棋棋手，取值为 1 或 2
 * @num_to_win: 棋盘判定胜负依据，为胜利时连子数量。默认为 5。
 * @num_player: 玩家数量。默认为 2。
 */
struct gb_game {
	void *mem;
	char **board;
	int width, height;

	int turn;
	int num_to_win;
	int num_player;
};

/**
 * gb_is_valid_coord - 判断坐标是否合法
 *
 * @g: 当前游戏
 * @y: 当前游戏纵坐标
 * @x: 当前游戏横坐标
 *
 * Return: 一个整数值，表示检查结果
 * * 0 - 该坐标不合法
 * * 1 - 该坐标合法
 */
int gb_is_valid_coord(struct gb_game *g, int y, int x)
{
	return 0 <= y && y < g->height && 0 <= x && x < g->width;
}

/**
 * gb_get_mem - 分配一局游戏所需内存
 *
 * @size: 所需内存大小
 *
 * Return: 一个 gb_game 的指针，为分配结果
 * * * NULL - 分配失败
 * * * 其他结果 - 分配成功
 */
struct gb_game *gb_get_mem(size_t size)
{
	struct gb_game *g = 
		(struct gb_game *)malloc(sizeof(struct gb_game));
	if (g == NULL)
		return NULL;
	g->mem = malloc(size);
	if (g->mem == NULL) {
		free(g);
		return NULL;
	}
	return g;
}

/**
 * gb_set_vars - 设置游戏初值
 *
 * @g: 需要设置的游戏
 * @width: 棋盘宽度
 * @height: 棋盘高度
 *
 * Return: 一个整数，判断是否成功
 * * 0 - 设置成功
 * * 1 - 给定游戏不合法
 * * 2 - 棋盘大小不合法
 */
int gb_set_vars(struct gb_game *g, int width, int height)
{
	char *p;
	int i, j;

	if (g == NULL)
		return 1;

	if (width <= 0 || height <= 0)
		return 2;

	g->width = width;
	g->height = height;
	g->turn = 1;
	g->num_to_win = 5;
	g->num_player = 2;

	p = (char *)g->mem;

	/* mem 数组的前面一部分是一堆指针，用于构建 board 数组。后面的部分
	 * 是棋盘数据，用于保存当前棋盘状态。
	 *
	 * mem 数组的内存布局如下
	 *
	 * @mem
	 * ---------------- 前半部分
	 *  ---------
	 *  board[0]
	 *  ---------
	 *  board[1]
	 *  ---------
	 *  ....
	 *  ---------
	 *  board[height - 1]
	 *  ---------
	 * ---------------- 后半部分
	 *  [ board[0][0] | board[0][1] | ... board[0][width - 1] ]
	 *  [ board[1][0] | board[1][1] | ... board[1][width - 1] ]
	 *  [ board[2][0] | board[2][1] | ... board[2][width - 1] ]
	 *  [ board[3][0] | board[3][1] | ... board[3][width - 1] ]
	 *  ...
	 *  [ board[height - 1][0] ... ]
	 * ----------------
	 *
	 * 实际上如果只有 mem 数组，砍掉前半存放 board 的部分，也可以实现
	 * 所有功能。但是加入 board 数组后可以少写很多奇怪的坐标运算，写起
	 * 来也更不容易错。
	 *
	 * 为什么不采用先分配一个 board，然后把 board 里的每一个指针依次分
	 * 配一行内存，而是先开一个大 mem 再设置指针指向 mem 中的内容呢？
	 * 因为如果之后有超级神秘需求比如进程间传递一个棋盘、把棋盘通过
	 * 网络发送之类的会变得方便一些……
	 *
	 * 主要还是怕释放的时候写错。
	 */
	g->board = (char **)p;
	p += sizeof(char *) * height;
	for (i = 0; i < height; ++i) {
		g->board[i] = (char *)p;
		p += sizeof(char) * width;
	}

	for (i = 0; i < height; ++i)
		for (j = 0; j < width; ++j)
			g->board[i][j] = 0;

	return 0;
}

/**
 * gb_init_game - 初始化游戏
 *
 * 它目前只是 gb_set_vars 的别名，未来增加新的玩法时可能会修改该函数。
 */
int gb_init_game(struct gb_game *g, int width, int height)
{
	return gb_set_vars(g, width, height);
}

/**
 * gb_del_game - 删除游戏并释放内存
 *
 * @g: 需要删除的游戏
 *
 * Return: 一个整数，判断是否成功
 * * 0 - 删除成功
 */
int gb_del_game(struct gb_game *g)
{
	free(g->mem);
	free(g);
	return 0;
}

/**
 * gb_new_game - 分配内存并新建一个游戏
 *
 * @height: 棋盘高度
 * @width: 棋盘宽度
 *
 * Return: 一个指针
 * * NULL - 游戏创建时出错
 * * 其它值 - 创建成功
 */
struct gb_game *gb_new_game(int height, int width)
{
	struct gb_game *g = gb_get_mem(sizeof(char *) * height
			+ sizeof(char) * width * height);

	if (g == NULL)
		return NULL;

	if (gb_init_game(g, width, height)) {
		gb_del_game(g);
		return NULL;
	}

	return g;
}

/**
 * gb_game_over_check_line - 检查玩家是否在某一个点的给定方向连线上是否有
 * 多于或等于 -num_to_win 个棋子
 *
 * @g - 当前游戏
 * @player - 游戏玩家
 * @dy - 方向的纵坐标
 * @dx - 方向的横坐标
 * @y - 待检查点的纵坐标
 * @x - 待检查点的纵坐标
 *
 * Return: 一个整数，表示玩家是否有多于或等于 -num_to_win 个棋子
 * * 0 - 否
 * * 1 - 是
 */
int gb_game_over_check_line(struct gb_game *g, int player,
		int dy, int dx, int y, int x)
{
	int cnt = 0;

	while (gb_is_valid_coord(g, y, x)) {
		if (g->board[y][x] == player) {
			if (++cnt == g->num_to_win)
				return 1;
		} else {
			cnt = 0;
		}

	       	y += dy, x += dx;
	}

	return 0;
}

/**
 * gb_is_player_win_at_pos - 检查玩家是否在某一个点的八个方向连线上是否有
 * 多于或等于 -num_to_win 个棋子
 *
 * @g - 当前游戏
 * @player - 游戏玩家
 * @y - 待检查点的纵坐标
 * @x - 待检查点的纵坐标
 *
 * Return: 一个整数，表示玩家是否有多于或等于 -num_to_win 个棋子
 * * 0 - 否
 * * 1 - 是
 */
int gb_is_player_win_at_pos(struct gb_game *g, int player, int y, int x)
{
	int i, j;

	/* 枚举八个方向 */
	for (i = -1; i <= 1; ++i)
		for (j = -1; j <= 1; ++j)
			if ((i || j) && gb_game_over_check_line(
						g, player, i ,j, y, x))
				return 1;

	return 0;
}

/**
 * gb_is_game_end_in_draw - 检查是否陷入死局
 *
 * @g - 当前游戏
 * @player - 游戏玩家
 * @y - 待检查点的纵坐标
 * @x - 待检查点的纵坐标
 *
 * Return: 一个整数，是否死局
 * * 0 - 否
 * * 1 - 是
 */
int gb_is_game_end_in_draw(struct gb_game *g)
{
	int i, j;

	/* 检查棋盘上是否有空地 */
	for (i = 0; i < g->width; ++i)
		for (j = 0; j < g->height; ++j)
			if (g->board[i][j] == 0)
				return 0;
	return 1;
}

/**
 * gb_game_over - 检查游戏是否结束
 *
 * @g - 当前游戏
 *
 * Return: 一个有符号整数
 * * -1 - 游戏以平局结束
 * * 0 - 游戏未结束
 * * 正数 - 获胜玩家编号
 */
int gb_game_over(struct gb_game *g)
{
	int i, j;

	/* 先判断每个点的八个方向是否胜利
	 * 然后再判断是否平局
	 */
	for (i = 0; i < g->width; ++i)
		for (j = 1; j <= g->num_player; ++j)
			if (gb_is_player_win_at_pos(g, j, 0, i) ||
					gb_is_player_win_at_pos(g, j, g->height - 1, i))
				return j;

	for (i = 0; i < g->height; ++i)
		for (j = 1; j <= g->num_player; ++j)
			if (gb_is_player_win_at_pos(g, j, i, 0) ||
					gb_is_player_win_at_pos(g, j, i, g->width - 1))
				return j;

	if (gb_is_game_end_in_draw(g))
		return -1;

	return 0;
}

/* gb_place_stone - 在指定位置放置一个棋子
 *
 * @g: 当前游戏
 * @y: 放置棋子的纵坐标
 * @x: 放置棋子的横坐标
 *
 * Return: 一个整数，表示放置是否成功
 * * 0 - 放置成功
 * * 1 - 坐标不合法
 * * 2 - 待放置的位置已经有棋子
 */
int gb_place_stone(struct gb_game *g, int y, int x)
{
	if (!gb_is_valid_coord(g, y, x))
		return 1;
	if (g->board[y][x] != 0)
		return 2;

	g->board[y][x] = g->turn;

	++g->turn;
	if (g->turn > g->num_player)
		g->turn = 1;

	return 0;
}

/**
 * read_cmd - 读取输入指令
 *
 * Return: 一个整数，字符，读取到的指令
 */
int read_cmd(void)
{
	int ch;
	do {
		ch = tm_getch();
		if (ch == EOF)
			return 'q';
	} while (strchr("wasdoqrR", ch) == NULL);
	return ch;
}

/**
 * print_board - 打印游戏棋盘
 *
 * @g: 当前游戏
 * @cur_y: 光标的纵坐标
 * @cur_x: 光标的横坐标
 *
 * Return: 一个整数，表示是否成功
 * * 0 - 成功
 */
int print_board(struct gb_game *g, int cur_y, int cur_x)
{
	int i, j;
	puts("! ! G O B A N G ! !");
	for (i = 0; i < g->width * 3 + 2; ++i)
		putchar('=');
	putchar('\n');

	putchar('+');
	for (i = 0; i < g->width * 3; ++i)
		putchar('-');
	putchar('+');
	putchar('\n');
	for (i = 0; i < g->height; ++i) {
		putchar('|');
		for (j = 0; j < g->width; ++j)
			printf("%c%c%c",
				       	i == cur_y && j == cur_x ? '<' : ' ',
					g->board[i][j] == 1 ? '@' :
					g->board[i][j] == 2 ? 'O' :
					' ',
					i == cur_y && j == cur_x ? '>' : ' '
			      );
		putchar('|');
		putchar('\n');
	}

	putchar('+');
	for (i = 0; i < g->width * 3; ++i)
		putchar('-');
	putchar('+');
	putchar('\n');

	printf("Turn: Player %d\n", g->turn);
	printf("HEIGHT: %d  WIDTH: %d\n", g->height, g->width);
	printf("%s",
			" KEY BINDINGS\n"
			"   [w]            [o] place a stone\n"
			"[a]   [d]  MOVE   [q] quit the game\n"
			"   [s]            [r] restart the game\n"
			"                  [R] change the size of board\n"
	      );
	puts("");

	return 0;
}

int main(void)
{
	int cur_y = 0, cur_x = 0;
	int win = 0;
	int height = 10, width = 10;
	struct gb_game *g = gb_new_game(height, width);

	tm_clear();
	while ((win = gb_game_over(g)) == 0) {
		int cmd;
		tm_set();
		print_board(g, cur_y, cur_x);
		cmd = read_cmd();

		switch (cmd) {
			case 'w':
				if (gb_is_valid_coord(g, cur_y - 1, cur_x))
					--cur_y;
				break;
			case 's':
				if (gb_is_valid_coord(g, cur_y + 1, cur_x))
					++cur_y;
				break;
			case 'a':
				if (gb_is_valid_coord(g, cur_y, cur_x - 1))
					--cur_x;
				break;
			case 'd':
				if (gb_is_valid_coord(g, cur_y, cur_x + 1))
					++cur_x;
				break;
			case 'q':
				puts("Game ended");
				goto out;
				break;
			case 'o':
				gb_place_stone(g, cur_y, cur_x);
				break;
			case 'R':
				cur_y = cur_x = 0;
				puts("Enter height and width:");
				scanf("%d%d", &height, &width);
				tm_clear();
				/* fall through */
			case 'r':
				gb_del_game(g);
				g = gb_new_game(height, width);
				break;
			default:
				break;
		}
	}

	tm_set();
	print_board(g, cur_y, cur_x);

	if (win == -1)
		printf("Ended in a draw\n");
	else
		printf("Game over, player %d wins\n", win);

out:

	gb_del_game(g);

	puts("Press 'q' to quit...");

	while (tm_getch() != 'q')
		;

	return 0;
}
```
