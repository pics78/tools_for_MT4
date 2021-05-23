// ScreenUtils

// [ツール一覧]
// ===================================================
// - シンボルラベル（画面右下に現在表示している通貨ペアを表示）
// - 現在日時（画面右上に現在価格を秒単位で表示）
// - ターゲットライン（現在価格から上下に指定pipsだけ離れた価格にラインをひく）
// ===================================================

#property copyright "pics78"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define SYMBOL_LABEL    "symbolLabel"
#define TIME_LABEL      "timeLabel"
#define TARGET_HL_LABEL "targetHighLine"
#define TARGET_LL_LABEL "targetLowLine"

const string DayOfWeekStr[7] =
   {"日", "月", "火", "水", "木", "金", "土"};

const int Periods[9] =
   {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};

extern color symbolLabelColor = Blue; // シンボルラベルの色
extern color timeLabelColor = Black; // 時刻ラベルの色
extern ENUM_TIMEFRAMES maxPeriodForTargetLine = PERIOD_H1; // ターゲットを表示する最大時間軸
extern double targetLinePips = 10.0; // 現在価格からターゲットまでの距離[pips]
extern color targetHLineColor = Crimson; // 上方ターゲットラインの色
extern color targetLLineColor = Crimson; // 下方ターゲットラインの色
extern ENUM_LINE_STYLE targetLineStyle = STYLE_DASH; // ターゲットラインのスタイル（上下共通）

int OnInit() {
   EventSetTimer(1);
   createSymbolLabel();
   createTimeLabel();
   createTargetLine();
   
   return 0;
}

void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectDelete(0, SYMBOL_LABEL);
   ObjectDelete(0, TIME_LABEL);
   ObjectDelete(0, TARGET_HL_LABEL);
   ObjectDelete(0, TARGET_LL_LABEL);
}

void OnTimer() {
   datetime now = TimeLocal();
   int mon  = TimeMonth(now);
   int day  = TimeDay(now);
   int hour = TimeHour(now);
   int min  = TimeMinute(now);
   int sec  = TimeSeconds(now);
   int dw   = TimeDayOfWeek(now);
   setTimeOnLabel(
      StringFormat("%d/%d(%s) %02d:%02d:%02d", mon, day, DayOfWeekStr[dw], hour, min, sec));
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
   
   updateTargetLine();
   return rates_total;
}

void createSymbolLabel() {
   ObjectCreate(0, SYMBOL_LABEL, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);  
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_XDISTANCE, 0);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_YDISTANCE, 0);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_COLOR, symbolLabelColor);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_BACK, false);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_ZORDER, 0);
   ObjectSetInteger(0, SYMBOL_LABEL, OBJPROP_FONTSIZE, 25);
   string symbol = StringSubstr(Symbol(), 0, 6);
   string period = Period() == PERIOD_M1  ? "M1"  :
                   Period() == PERIOD_M5  ? "M5"  :
                   Period() == PERIOD_M15 ? "M15" :
                   Period() == PERIOD_M30 ? "M30" :
                   Period() == PERIOD_H1  ? "H1"  :
                   Period() == PERIOD_H4  ? "H4"  :
                   Period() == PERIOD_D1  ? "D1"  :
                   Period() == PERIOD_W1  ? "W1"  :
                   Period() == PERIOD_MN1 ? "MN"  : "";
   ObjectSetString(0, SYMBOL_LABEL, OBJPROP_TEXT, symbol + " " + period);
}

void createTimeLabel() {
   ObjectCreate(0, TIME_LABEL, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);  
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_XDISTANCE, 0);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_YDISTANCE, 20);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_COLOR, timeLabelColor);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_BACK, false);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_ZORDER, 0);
   ObjectSetInteger(0, TIME_LABEL, OBJPROP_FONTSIZE, 15);
   ObjectSetString(0, TIME_LABEL, OBJPROP_FONT, "ＭＳ Ｐゴシック");
   ObjectSetString(0, TIME_LABEL, OBJPROP_TEXT, "日付取得中...");
}

void setTimeOnLabel(string timeStr) {
   ObjectSetString(0, TIME_LABEL, OBJPROP_TEXT, timeStr);
}

void createTargetLine() {
   ObjectCreate(0, TARGET_HL_LABEL, OBJ_HLINE, 0, 0, 0);
   ObjectCreate(0, TARGET_LL_LABEL, OBJ_HLINE, 0, 0, 0);
   ObjectSetInteger(0, TARGET_HL_LABEL, OBJPROP_COLOR, targetHLineColor);
   ObjectSetInteger(0, TARGET_LL_LABEL, OBJPROP_COLOR, targetLLineColor);
   ObjectSetInteger(0, TARGET_HL_LABEL, OBJPROP_STYLE, targetLineStyle);
   ObjectSetInteger(0, TARGET_LL_LABEL, OBJPROP_STYLE, targetLineStyle);
   
   uint timeframesWithTarget = getTimeframesWithTarget();
   ObjectSetInteger(0,TARGET_HL_LABEL , OBJPROP_TIMEFRAMES , timeframesWithTarget);
   ObjectSetInteger(0,TARGET_LL_LABEL , OBJPROP_TIMEFRAMES , timeframesWithTarget);
   
   updateTargetLine();
}

void updateTargetLine() {
   ObjectSet(TARGET_HL_LABEL, OBJPROP_PRICE1, Bid + Point*10.0*targetLinePips);
   ObjectSet(TARGET_LL_LABEL, OBJPROP_PRICE1, Ask - Point*10.0*targetLinePips);
}

uint getTimeframesWithTarget() {
   uint result = 0x0;
   for (int i=0; i<ArraySize(Periods); i++) {
      if (Periods[i] <= maxPeriodForTargetLine) {
         result = result | (OBJ_PERIOD_M1 << i);
      } else {
         break;
      }
   }
   return result;
}