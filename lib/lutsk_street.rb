require_relative 'ee_strings'
# require 'rgeo/shapefile'

class LutskStreet
  STREETS = [
    { name: "1-й Збаразький провулок", latitude: 50.7215292, longitude: 25.3735973 },
    { name: "1-й Малоомелянівський провулок", latitude: 50.7304044, longitude: 25.282384 },
    { name: "1-й Степовий провулок", latitude: 50.000000, longitude: 25.000000 },
    { name: "1-й провулок Трутовського", latitude: 50.000000, longitude: 25.000000 },
    { name: "2-й Збаразький провулок", latitude: 50.000000, longitude: 25.000000 },
    { name: "2-й Малоомелянівський провулок", latitude: 50.7314691, longitude: 25.2835369 },
    { name: "2-й Степовий провулок", latitude: 50.000000, longitude: 25.000000 },
    { name: "2-й провулок Трутовського", latitude: 50.000000, longitude: 25.000000 },
    { name: "3-й Малоомелянівський провулок", latitude: 50.7321037, longitude: 25.282947 },
    { name: "3-й Степовий провулок", latitude: 50.000000, longitude: 25.000000 },
    { name: "3-й провулок Трутовського", latitude: 50.000000, longitude: 25.000000 },
    { name: "4-й Малоомелянівський провулок", latitude: 50.7326628, longitude: 25.2833985 },
    { name: "4-й Степовий провулок", latitude: 50.000000, longitude: 25.000000 },
    { name: "5-й Малоомелянівський провулок", latitude: 50.7337104, longitude: 25.2821886 },
    { name: "6-й Малоомелянівський провулок", latitude: 50.000000, longitude: 25.000000 },
    { name: "7-й Малоомелянівський провулок", latitude: 50.000000, longitude: 25.000000 },
    { name: "8-го Березня", latitude: 50.000000, longitude: 25.000000 },
    { name: "8-й Малоомелянівський провулок", latitude: 50.000000, longitude: 25.000000 },
    { name: "Авіаторів", latitude: 50.7679206, longitude: 25.3407177 },
    { name: "Агатангела Кримського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Агрономічна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Айвазовського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Андрія Марцинюка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Андрузького Григорія", latitude: 50.000000, longitude: 25.000000 },
    { name: "Арцеулова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Авторемонтна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Астрономічна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Баженова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Базарна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Балакірєва", latitude: 50.000000, longitude: 25.000000 },
    { name: "Балтійська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Балка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Бандери Степана", latitude: 50.000000, longitude: 25.000000 },
    { name: "Баранова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Баранова, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Баумана", latitude: 50.000000, longitude: 25.000000 },
    { name: "Безіменна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Бенделіані", latitude: 50.000000, longitude: 25.000000 },
    { name: "Березова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Берестечківська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Берестова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Бесараб Ольги", latitude: 50.000000, longitude: 25.000000 },
    { name: "Бічна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Богдана Хмельницького", latitude: 50.000000, longitude: 25.000000 },
    { name: "Богачука Олександра (Щорса)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Богомольця", latitude: 50.000000, longitude: 25.000000 },
    { name: "Боженка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Євгена Сверстюка (Бойка)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Болбочана Петра (Кірова)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Боровиковського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Бородіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Боткіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Братковського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Братський міст, майдан", latitude: 50.000000, longitude: 25.000000 },
    { name: "Брестська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Бринського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Брюллова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Будівельників", latitude: 50.000000, longitude: 25.000000 },
    { name: "Бурчака Нестора", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вавилова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Валерії Новодворської (Ванди Василевської)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Варварівка (Чапаєва)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Василя Стуса", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ватутіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вахтангова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вербова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вересая", latitude: 50.000000, longitude: 25.000000 },
    { name: "Борохівська (Вереснева)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Верещагіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вериківського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Весела", latitude: 50.000000, longitude: 25.000000 },
    { name: "Весняна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ветеранів", latitude: 50.000000, longitude: 25.000000 },
    { name: "Виговського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Винниченка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вишенського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вишківська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вишківський, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вишнева", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вишнівецька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Відродження, проспект", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вільхова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вільямса", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вітковського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Воїнів Інтернаціоналістів", latitude: 50.000000, longitude: 25.000000 },
    { name: "Волгоградська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Волинська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Волі, проспект", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шумука Данила (Володарського)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Володимирська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Павла Пащевського (Вацлава Воровського)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Вороніхіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гаврилюка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гайдамацька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Галшки Гулевичівни (Савельєвої Паші)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гастелло", latitude: 50.000000, longitude: 25.000000 },
    { name: "Генерала Шухевича (Кузнєцова)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Героїв УПА (Червоноармійська)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гетьмана Дорошенка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гетьмана Мазепи", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гетьмана Сагайдачного", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гірна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Глибока", latitude: 50.000000, longitude: 25.000000 },
    { name: "Глібова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Глієра", latitude: 50.000000, longitude: 25.000000 },
    { name: "Глінки", latitude: 50.000000, longitude: 25.000000 },
    { name: "Глушець", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гнатюка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гнідавська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гнідавський, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Говорова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гоголя", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гонгадзе Георгія (Лазо)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гончара", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гончарівка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гончарова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гордіюк", latitude: 50.000000, longitude: 25.000000 },
    { name: "Горіхова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Горішня", latitude: 50.000000, longitude: 25.000000 },
    { name: "Городецька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Горохова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Госпітальна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гостинна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Грабова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Грабовського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Градний узвіз", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гребінки", latitude: 50.000000, longitude: 25.000000 },
    { name: "Грекова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гречана", latitude: 50.000000, longitude: 25.000000 },
    { name: "Григорія Андрузького", latitude: 50.000000, longitude: 25.000000 },
    { name: "Григорія Гуляницького (Радгоспна)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гризодубової", latitude: 50.000000, longitude: 25.000000 },
    { name: "Грибоєдова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Грінченка, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Громової", latitude: 50.000000, longitude: 25.000000 },
    { name: "Грушевського, майдан", latitude: 50.000000, longitude: 25.000000 },
    { name: "Грушевського, проспект", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гулака-Артемовського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Гущанська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Далека", latitude: 50.000000, longitude: 25.000000 },
    { name: "Данила Галицького", latitude: 50.000000, longitude: 25.000000 },
    { name: "Даньшина", latitude: 50.000000, longitude: 25.000000 },
    { name: "Дарвіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Даргомижського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Дачна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Декабристів", latitude: 50.000000, longitude: 25.000000 },
    { name: "Донцова Дмитра", latitude: 50.000000, longitude: 25.000000 },
    { name: "Донцова Дмитра, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Дністрянського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Дністровського Станіслава", latitude: 50.000000, longitude: 25.000000 },
    { name: "Добролюбова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Довженка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Докучаєва", latitude: 50.000000, longitude: 25.000000 },
    { name: "Дорожний, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Драгоманова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Дружби Народів, бульв.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Дубнівська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Дубова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Електроапаратна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Єрмолової", latitude: 50.000000, longitude: 25.000000 },
    { name: "Єршова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Волноваська (Жовтнева)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Жуковського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Журавлина", latitude: 50.000000, longitude: 25.000000 },
    { name: "Заводська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Загородня", latitude: 50.000000, longitude: 25.000000 },
    { name: "Залізна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Залізнична", latitude: 50.000000, longitude: 25.000000 },
    { name: "Залізняка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Замкова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Заньковецької", latitude: 50.000000, longitude: 25.000000 },
    { name: "Заповітна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Запорізька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Зарічна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Застав'я", latitude: 50.000000, longitude: 25.000000 },
    { name: "Затишна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Захарова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Західна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Зацепи", latitude: 50.000000, longitude: 25.000000 },
    { name: "Збаразька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Зв'язківців", latitude: 50.000000, longitude: 25.000000 },
    { name: "Зелена", latitude: 50.000000, longitude: 25.000000 },
    { name: "Земнухова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Задворецька (Зої Космодем'янської)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ізмайлова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Індустріальна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кондзелевича Іова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кожедуба Івана (Чкалова)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Калинова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Караїмська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Карбишева", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кармелюка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Карпенка-Карого", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кафедральна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Качалова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Качалова, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Каштанова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Квітова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Київський, майдан", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ківерцівська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кічкарівська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Уласа Самчука (Клари Цеткін)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кленова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Клима Савура", latitude: 50.000000, longitude: 25.000000 },
    { name: "Княгинівська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Князів Острозьких (Краснодонців)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Князів Ружинських (Земнухова)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кобилянської", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ковалевської", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ковельська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ковпака", latitude: 50.000000, longitude: 25.000000 },
    { name: "Козакова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кольцова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Комка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Комунальний, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кондратюка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Коновальця Євгена", latitude: 50.000000, longitude: 25.000000 },
    { name: "Конякіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кооперативна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Копачівська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Коперника", latitude: 50.000000, longitude: 25.000000 },
    { name: "Корнійчука", latitude: 50.000000, longitude: 25.000000 },
    { name: "Короленка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Корольова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Коротка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Миколи Куделі (Коротченка)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Космонавтів", latitude: 50.000000, longitude: 25.000000 },
    { name: "Костопільська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Котляревського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Олекси Ошуркевича (Коцька)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Коцюбинського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кочерги", latitude: 50.000000, longitude: 25.000000 },
    { name: "Балківська (Кошового Олега)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кравчука", latitude: 50.000000, longitude: 25.000000 },
    { name: "Красовського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Красовського, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кременецька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кривий Вал", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кривенького Степана (Фрунзе)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кривоноса", latitude: 50.000000, longitude: 25.000000 },
    { name: "Крилова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Крушельницької", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кульчинської Олени", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кульчицької", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кунцевича Йосафата (Громової Уляни)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Купали Янки", latitude: 50.000000, longitude: 25.000000 },
    { name: "Купріна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Леся Курбаса", latitude: 50.000000, longitude: 25.000000 },
    { name: "Курська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Курчатова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Кутузова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ландау", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ланова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Левадна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Левітана", latitude: 50.000000, longitude: 25.000000 },
    { name: "Леонтовича", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лесі Українки", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лермонтова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лєскова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Липинська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Липинського В'ячеслава", latitude: 50.000000, longitude: 25.000000 },
    { name: "Липлянська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Липова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Липовецька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лисенка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лідавська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Літня", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лобачевського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ломоносова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лопатіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лугова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лютеранська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Лятошинського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Львівська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Львівський, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мазурця Степана (Морозова Павлика)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ростислава Волошина (Макаревича)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Макаренка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Макарова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Маковського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Малинова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Малоомелянівська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мамсурова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мазепи Івана", latitude: 50.000000, longitude: 25.000000 },
    { name: "Марка Вовчка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Марцинюка Андрія (Тухачевського)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Матросова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Маха Петра (Баумана)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мельнична", latitude: 50.000000, longitude: 25.000000 },
    { name: "Менделєєва", latitude: 50.000000, longitude: 25.000000 },
    { name: "Метельницького Архітектора (Бринського)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Механічна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мечнікова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Міхновського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Микулицька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Милушська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Миру", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мисливська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Міліційна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мінська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Міхновського Миколи", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мічуріна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Можайського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Млинова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Могили Петра (Тюленіна)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мойсея Василя, проспект", latitude: 50.000000, longitude: 25.000000 },
    { name: "Молоді, проспект", latitude: 50.000000, longitude: 25.000000 },
    { name: "Молодіжна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Молодогвардійська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Млинівська (Молодогвардійців)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Морозова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Хурсенка В'ячеслава (Московська)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Мурашка", latitude: 50.000000, longitude: 25.000000 },
    { name: "На таборищі", latitude: 50.000000, longitude: 25.000000 },
    { name: "Набережна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Нагірна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Надозерна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Надрічна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Наливайка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Народних Дружинників", latitude: 50.000000, longitude: 25.000000 },
    { name: "Нахімова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Невського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Нестерова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Нечуя-Левицького", latitude: 50.000000, longitude: 25.000000 },
    { name: "Нижній проїзд", latitude: 50.000000, longitude: 25.000000 },
    { name: "Нижня", latitude: 50.000000, longitude: 25.000000 },
    { name: "Нікішева", latitude: 50.000000, longitude: 25.000000 },
    { name: "Нова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Новочерчицька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Овочева", latitude: 50.000000, longitude: 25.000000 },
    { name: "Огієнка Івана", latitude: 50.000000, longitude: 25.000000 },
    { name: "Озерецька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Окружна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Олександра Богачука", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ошуркевича", latitude: 50.000000, longitude: 25.000000 },
    { name: "Олени Теліги", latitude: 50.000000, longitude: 25.000000 },
    { name: "Олицька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ольжича Олега", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ольхова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Орджонікідзе", latitude: 50.000000, longitude: 25.000000 },
    { name: "Островського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Острозьких князів", latitude: 50.000000, longitude: 25.000000 },
    { name: "Офіцерська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Павлова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Павлюка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Панаса Мирного", latitude: 50.000000, longitude: 25.000000 },
    { name: "Панфілова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Папаніна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Паркова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Партизанська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Пархоменка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Патона", latitude: 50.000000, longitude: 25.000000 },
    { name: "Паторжинського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Педагогічна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Перемоги, проспект", latitude: 50.000000, longitude: 25.000000 },
    { name: "Перовської Софії", latitude: 50.000000, longitude: 25.000000 },
    { name: "Петрова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Петрусенка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Пилипа Орлика", latitude: 50.000000, longitude: 25.000000 },
    { name: "Пирогова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Писаревського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Південна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Північна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Підгаєцька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Пінська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Плитниця", latitude: 50.000000, longitude: 25.000000 },
    { name: "Поліська Січ", latitude: 50.000000, longitude: 25.000000 },
    { name: "Покальчуків (Свердлова)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Полонківська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Польова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Поморська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Попова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Потапова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Потебні", latitude: 50.000000, longitude: 25.000000 },
    { name: "Поштова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Прасолів", latitude: 50.000000, longitude: 25.000000 },
    { name: "Пржевальського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Привітна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Привокзальна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Привокзальний майдан", latitude: 50.000000, longitude: 25.000000 },
    { name: "Прилуцька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Прилуцький, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Прогресу", latitude: 50.000000, longitude: 25.000000 },
    { name: "Проектувальна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Пролетарська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Профспілкова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Путінцева", latitude: 50.000000, longitude: 25.000000 },
    { name: "Пушкіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "П'ятницька гірка (Горького)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Радіщева", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ранкова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Рахманінова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Революційна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ревуцького", latitude: 50.000000, longitude: 25.000000 },
    { name: "Рєпіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Рилєєва", latitude: 50.000000, longitude: 25.000000 },
    { name: "Рильського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ринок", latitude: 50.000000, longitude: 25.000000 },
    { name: "Рівненська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Річна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Робітнича", latitude: 50.000000, longitude: 25.000000 },
    { name: "Рогова (Пролетарська)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Романюка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Руданського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Руська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Савури Клима", latitude: 50.000000, longitude: 25.000000 },
    { name: "Садова (Колгоспна)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Садовий (Колгоспний), пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Садовського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Саксаганського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Самчука Уласа", latitude: 50.000000, longitude: 25.000000 },
    { name: "Салтикова-Щедріна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сапалаївська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Саперів", latitude: 50.000000, longitude: 25.000000 },
    { name: "Свердлова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Світла", latitude: 50.000000, longitude: 25.000000 },
    { name: "Севастопольська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Селищна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сенатора", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сенаторки Левчанівської (Медвєдєва)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сєчєнова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Симиренка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сільська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Січова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сковороди", latitude: 50.000000, longitude: 25.000000 },
    { name: "Скрябіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Словацького", latitude: 50.000000, longitude: 25.000000 },
    { name: "Смелякова, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Смирнова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Соборності, проспект", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сонячна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Соснова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сосюри", latitude: 50.000000, longitude: 25.000000 },
    { name: "Срібна (Радіщева)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Спортивна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ставки", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сталева", latitude: 50.000000, longitude: 25.000000 },
    { name: "Станіславського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Стара дорога", latitude: 50.000000, longitude: 25.000000 },
    { name: "Старицького", latitude: 50.000000, longitude: 25.000000 },
    { name: "Старицького, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Старова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Старосільська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Степова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Стефаника", latitude: 50.000000, longitude: 25.000000 },
    { name: "Стефаника, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Стецька Ярослава", latitude: 50.000000, longitude: 25.000000 },
    { name: "Стирова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Стрельникова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Стрілецька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Струтинського Миколи, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Супутникова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сурикова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Сухомлинського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Східна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тараса Бульби-Боровця", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тарасова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Театральна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Театральний, майдан", latitude: 50.000000, longitude: 25.000000 },
    { name: "Теремнівська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тесленка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Теліги Олени", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тещин язик, проїзд", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тиха", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тімірязєва", latitude: 50.000000, longitude: 25.000000 },
    { name: "Товарова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Торгова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тополина", latitude: 50.000000, longitude: 25.000000 },
    { name: "Троїцька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Трудова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Трункіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Трутовського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Туполєва", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тургенєва", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тюленіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Тютюнника Юрія (Урицького)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Учительська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ушинського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ужвій Наталії (Бєлінського)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Фабрична", latitude: 50.000000, longitude: 25.000000 },
    { name: "Федорова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Фестивальна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Філатова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Фільваркова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Фільтрова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Франка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Фрунзе", latitude: 50.000000, longitude: 25.000000 },
    { name: "Олекси Алмазова (Фурманова)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Хакімова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Хасевича Ніла", latitude: 50.000000, longitude: 25.000000 },
    { name: "Холмська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Холодноярська (Котовського)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Хотинська", latitude: 50.000000, longitude: 25.000000 },
    { name: "Християнська (Доватора)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Цегельна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Центральна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ціолковського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Цукрова (Невського)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Чайковського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Чекаліна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Челюскіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Червоного Хреста", latitude: 50.000000, longitude: 25.000000 },
    { name: "Червоної Калини (Паризької комуни)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Чернишевського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Черняховського", latitude: 50.000000, longitude: 25.000000 },
    { name: "Черчицька", latitude: 50.000000, longitude: 25.000000 },
    { name: "Чехова", latitude: 50.000000, longitude: 25.000000 },
    { name: "Чорновола В'ячеслава", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шевцової", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шевченка", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шишкіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шкільна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шопена", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шептицького Андрея Митрополита (Орджонікідзе)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шота Руставелі", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шота Руставелі, пров.", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шпитальна (Бабушкіна)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шума Олексія (Куйбишева)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Шухевича Генерала (Кузнєцова)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Щедріна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Щепкіна", latitude: 50.000000, longitude: 25.000000 },
    { name: "Щусєва", latitude: 50.000000, longitude: 25.000000 },
    { name: "Янки Купали", latitude: 50.000000, longitude: 25.000000 },
    { name: "Яблунева (Пархоменка)", latitude: 50.000000, longitude: 25.000000 },
    { name: "Яровиця", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ярощука", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ясенева", latitude: 50.000000, longitude: 25.000000 },
    { name: "Ясна", latitude: 50.000000, longitude: 25.000000 }
  ].freeze

  def self.like_name(name)
    STREETS.select do |street|
      begin
        Regexp.new(name.downcase_utf8_cyr) =~ street[:name].downcase_utf8_cyr
      rescue => detail
        p detail
        false
      end
    end.map do |street|
      street[:name]
    end
  end

  # def self.read_streets
  #   RGeo::Shapefile::Reader.open(File.dirname(__FILE__) + '/shp/roads.shp') do |file|
  #     puts "File contains #{file.num_records} records."
  #     file.each do |record|
  #       if record.attributes['type'] == 'tertiary' && record.attributes['name'] != ''
  #         puts "Record number #{record.index}:"
  #         puts "  Geometry: #{record.geometry.as_text}"
  #         puts "  Attributes: #{record.attributes.inspect}"
  #       end
  #     end
  #     # file.rewind
  #     # record = file.next
  #     # puts "First record geometry was: #{record.geometry.as_text}"
  #   end
  # end
end
