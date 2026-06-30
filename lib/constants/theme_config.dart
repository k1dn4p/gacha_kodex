const defaultThemeName = 'Cherry';

const availableThemes = ['Cherry', 'Cinamoroll_2607'];

const Map<String,  int> defaultPrice = {
  'Cherry': 14000,
  'Cinamoroll_2607': 17000,
};

const Map<String, Map<String, int>> defaultPrizeCounts = {
  'Cherry': {
    'A': 3,
    'B': 2,
    'C': 2,
    'D': 6,
    'E': 10,
    'F': 11,
    'G': 18,
    'H': 18,
  },
  'Cinamoroll_2607': {
    'A': 2,
    'B': 4,
    'C': 6,
    'D': 10,
    'E': 10,
    'F': 10,
    'G': 8,
    'H': 5,
    'I': 5,
    'J': 5,
    'K': 5,
  },
};

const Map<String, Map<String, String>> prizeNames = {
  'Cherry': {
    'A': '사쿠라 피규어',
    'B': '봉인 지팡이 메이크업 브러쉬',
    'C': '머그컵',
    'D': '컴팩트 미러',
    'E': '식기 컬렉션',
    'F': '디포르메 아크릴 스탠드',
    'G': '문구 컬렉션',
    'H': '고무 컬렉션',
  },
  'Cinamoroll_2607': {
    'A': '시나모롤 헤드폰',
    'B': '시나모롤 누이구루미',
    'C': '시나모롤 데스크매트',
    'D': '시나모롤 릴리프 유리컵',
    'E': '시나모롤 마스코트',
    'F': '시나모롤 토트백',
    'G': '시나모롤 헤어 터번',
    'H': '시나모롤 바구니(하늘색)',
    'I': '시나모롤 바구니(흰색)',
    'J': '시나모롤 리본 챰(하늘색)',
    'K': '시나모롤 리본 챰(흰색)',
    'Lastone': '시나모롤 LED 거울',
  },
};
