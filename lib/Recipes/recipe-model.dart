//API Result Model
class RecipeModel {
  List<Result>? results; //list of recipes
  int? offset;
  int? number; //number of results to return
  int? totalResults; //total number of possible results

  RecipeModel({
    this.results = const [],
    this.offset,
    this.number,
    this.totalResults,
  });
}

//Recipe model for search results
class Result {
  bool vegetarian;
  bool vegan;
  bool glutenFree;
  bool dairyFree;
  bool veryHealthy;
  bool cheap;
  bool veryPopular;
  bool sustainable;
  bool lowFodmap;
  int weightWatcherSmartPoints;
  String gaps;
  int preparationMinutes;
  int cookingMinutes;
  int aggregateLikes;
  int healthScore;
  String creditsText;
  String license;
  String sourceName;
  double pricePerServing;
  int id;
  String title;
  int readyInMinutes;
  int servings;
  String sourceUrl;
  String image;
  String imageType;
  Nutrition nutrition;
  String summary;
  List<dynamic> cuisines;
  List<dynamic> dishTypes;
  List<dynamic> diets;
  List<dynamic> occasions;
  List<AnalyzedInstruction> analyzedInstructions;
  String spoonacularSourceUrl;

  Result({
    required this.vegetarian,
    required this.vegan,
    required this.glutenFree,
    required this.dairyFree,
    required this.veryHealthy,
    required this.cheap,
    required this.veryPopular,
    required this.sustainable,
    required this.lowFodmap,
    required this.weightWatcherSmartPoints,
    required this.gaps,
    required this.preparationMinutes,
    required this.cookingMinutes,
    required this.aggregateLikes,
    required this.healthScore,
    required this.creditsText,
    required this.license,
    required this.sourceName,
    required this.pricePerServing,
    required this.id,
    required this.title,
    required this.readyInMinutes,
    required this.servings,
    required this.sourceUrl,
    required this.image,
    required this.imageType,
    required this.nutrition,
    required this.summary,
    required this.cuisines,
    required this.dishTypes,
    required this.diets,
    required this.occasions,
    required this.analyzedInstructions,
    required this.spoonacularSourceUrl,
  });
}

class Equipment {
  int id;
  String name;
  String localizedName;
  String image;

  Equipment({
    required this.id,
    required this.name,
    required this.localizedName,
    required this.image,
  });
}

class Nutrition {
  List<Nutrient> nutrients;
  List<Property> properties;
  List<Flavanoid> flavonoids;
  List<Ingredient> ingredients;
  CaloricBreakdown caloricBreakdown;
  WeightPerServing weightPerServing;

  Nutrition({
    required this.nutrients,
    required this.properties,
    required this.flavonoids,
    required this.ingredients,
    required this.caloricBreakdown,
    required this.weightPerServing,
  });
}

class Nutrient {
  String name;
  double amount;
  String unit;
  double? percentOfDailyNeeds;

  Nutrient({
    required this.name,
    required this.amount,
    required this.unit,
    this.percentOfDailyNeeds,
  });
}

class Property {
  String name;
  double amount;
  String unit;

  Property({required this.name, required this.amount, required this.unit});
}

class Flavanoid {
  String name;
  double amount;
  String unit;

  Flavanoid({required this.name, required this.amount, required this.unit});
}

class Ingredient {
  int id;
  String name;
  double amount;
  String unit;
  List<Nutrient> nutrients;

  Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.nutrients,
  });
}

class CaloricBreakdown {
  double percentProtein;
  double percentFat;
  double percentCarbs;

  CaloricBreakdown({
    required this.percentProtein,
    required this.percentFat,
    required this.percentCarbs,
  });
}

class WeightPerServing {
  int amount;
  String unit;

  WeightPerServing({
    required this.amount,
    required this.unit,
  });
}

class AnalyzedInstruction {
  String name;
  List<Step> steps;

  AnalyzedInstruction({
    required this.name,
    required this.steps,
  });
}

class Step {
  int number;
  String step;
  List<Equipment> ingredients;
  List<Equipment> equipment;

  Step({
    required this.number,
    required this.step,
    required this.ingredients,
    required this.equipment,
  });
}