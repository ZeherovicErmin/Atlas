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


//Converts API list of Nutrition nutrients to Nutrient List
List<Nutrient> nutrientsListFromJson(List<dynamic> apiNutrientList) {
  List<Nutrient> nutrientsList = []; //List of Nutrients to be returned
  //Loops through "nutrient" list from API and maps
  //each nutrient to a Nutrient object, then adds that to the nutrients List
  apiNutrientList.forEach((n) {
    Nutrient nutrient = Nutrient(
        name: n["name"] as String,
        //checks if this value is int, if it is return 0.0 else return 
        //the value bc it is correct type (double)
        amount: n["amount"] is int ? 0.0 : n["amount"] as double,
        unit: n["unit"] as String,
        //checks if this value is int, if it is return 0.0 else return 
        //the value bc it is correct type (double)
        percentOfDailyNeeds: n["percentOfDailyNeeds"] is int
            ? 0.0
            : n["percentOfDailyNeeds"] as double); 

    nutrientsList.add(nutrient);
  });

  return nutrientsList;
}

//Converts API list of Nutrition properties to Property List
List<Property> propertiesListFromJson(List<dynamic> apiPropertyList) {
  List<Property> propertiesList = []; //List of Nutrients to be returned
  //Loops through "property" list from API and maps each property to a
  //Property object and adds that to the property List
  apiPropertyList.forEach((n) {
    Property property = Property(
        name: n["name"] as String,
        //checks if this value is int, if it is return 0.0 else return 
        //the value bc it is correct type (double)
        amount: n["amount"] is int ? 0.0 : n["amount"] as double,
        unit: n["unit"] as String);
    propertiesList.add(property);
  });

  return propertiesList;
}

//Converts API list of Nutrition flavanoids to Flavanoid List
List<Flavanoid> flavanoidsListFromJson(List<dynamic> apiFlavanoidList) {
  List<Flavanoid> flavanoidsList = []; //List of Nutrients to be returned
  //Loops through "flavanoid" list from API and maps each flavanoid to a 
  //Flavanoid object and adds that to the flavanoid List
  apiFlavanoidList.forEach((n) {
    Flavanoid flavanoid = Flavanoid(
        name: n["name"] as String,
        //checks if this value is int, if it is return 0.0 else return 
        //the value bc it is correct type (double)
        amount: n["amount"] is int ? 0.0 : n["amount"] as double,
        unit: n["unit"] as String);
    flavanoidsList.add(flavanoid);
  });

  return flavanoidsList;
}