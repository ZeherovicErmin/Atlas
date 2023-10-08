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

  //Converts Recipe API response to RecipeModel
  RecipeModel.fromJson(Map<String, dynamic> json) {
    List<Result> resultsList = [];
    json["results"].forEach((r) {
      //List of Nutrients mapped from API nutrients list
      List<Nutrient> nutrientsList =
          nutrientsListFromJson(r["nutrition"]["nutrients"]);

      //List of properties mapped from API nutrients list
      List<Property> propertiesList =
          propertiesListFromJson(r["nutrition"]["properties"]);

      //List of flavanoids mapped from API nutrients list
      List<Flavanoid> flavanoidsList =
          flavanoidsListFromJson(r["nutrition"]["flavonoids"]);

      //List of flavanoids mapped from API nutrients list
      List<Ingredient> ingredientsList =
          ingredientListFromJson(r["nutrition"]["ingredients"]);

      //Caloric Breakdown mapped from API
      CaloricBreakdown caloricBreakdownObj = CaloricBreakdown(
        percentProtein:
            r["nutrition"]["caloricBreakdown"]["percentProtein"] as double,
        percentFat: r["nutrition"]["caloricBreakdown"]["percentFat"] as double,
        percentCarbs:
            r["nutrition"]["caloricBreakdown"]["percentCarbs"] as double,
      );

      //Weight Per Serving data mapped from API
      WeightPerServing weightPerServingObj = WeightPerServing(
          amount: r["nutrition"]["weightPerServing"]["amount"] as int,
          unit: r["nutrition"]["weightPerServing"]["unit"] as String);

      //Object containing all of the nutrition data we mapped from the API
      Nutrition nutritionObj = Nutrition(
          nutrients: nutrientsList,
          properties: propertiesList,
          flavonoids: flavanoidsList,
          ingredients: ingredientsList,
          caloricBreakdown: caloricBreakdownObj,
          weightPerServing: weightPerServingObj);

      //List of recipe instructions mapped from the API
      List<AnalyzedInstruction> analyzedInstructionList =
          analyzedInstructionListFromJson(r["analyzedInstructions"]);

      //Recipe Search Result Object containing all data pertaining to a recipe
      //including all the data mapped from the API
      Result result = Result(
          vegetarian: r["vegetarian"] as bool,
          vegan: r["vegan"] as bool,
          glutenFree: r["glutenFree"] as bool,
          dairyFree: r["dairyFree"] as bool,
          veryHealthy: r["veryHealthy"] as bool,
          cheap: r["cheap"] as bool,
          veryPopular: r["veryPopular"] as bool,
          sustainable: r["sustainable"] as bool,
          lowFodmap: r["lowFodmap"] as bool,
          weightWatcherSmartPoints: r["weightWatcherSmartPoints"] as int,
          gaps: r["gaps"] as String,
          preparationMinutes: r["preparationMinutes"] as int,
          cookingMinutes: r["cookingMinutes"] as int,
          aggregateLikes: r["aggregateLikes"] as int,
          healthScore: r["healthScore"] as int,
          creditsText: r["creditsText"] as String,
          license: r["license"] as String,
          sourceName: r["sourceName"] as String,
          pricePerServing: r["pricePerServing"] as double,
          id: r["id"] as int,
          title: r["title"] as String,
          readyInMinutes: r["readyInMinutes"] as int,
          servings: r["servings"] as int,
          sourceUrl: r["sourceUrl"] as String,
          image: r["image"] as String,
          imageType: r["imageType"] as String,
          nutrition: nutritionObj,
          summary: r["summary"] as String,
          cuisines: r["cuisines"] as List<dynamic>,
          dishTypes: r["dishTypes"] as List<dynamic>,
          diets: r["diets"] as List<dynamic>,
          occasions: r["occasions"] as List<dynamic>,
          analyzedInstructions: analyzedInstructionList,
          spoonacularSourceUrl: r["spoonacularSourceUrl"] as String);
      resultsList.add(result);
    });

    results = resultsList;
    offset = json["offset"] as int;
    number = json["number"] as int;
    totalResults = json["totalResults"] as int;
  }
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

//Equipment data for cooking the recipes
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

//Recipe nutrition data
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

//Nutrition nutrients data
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

//Nutrition properties data
class Property {
  String name;
  double amount;
  String unit;

  Property({required this.name, required this.amount, required this.unit});
}

//Nutrition flavanoid data
class Flavanoid {
  String name;
  double amount;
  String unit;

  Flavanoid({required this.name, required this.amount, required this.unit});
}

//Ingredient Nutrition data
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

//Recipe Caloric Breakdown
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

//Recipe Weight per Serving
class WeightPerServing {
  int amount;
  String unit;

  WeightPerServing({
    required this.amount,
    required this.unit,
  });
}

//Instructions for cooking a recipe
class AnalyzedInstruction {
  String name;
  List<Step> steps;

  AnalyzedInstruction({
    required this.name,
    required this.steps,
  });
}

//Recipe instruction step
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

//Converts API list of Nutrition ingredients to Ingredient List
List<Ingredient> ingredientListFromJson(List<dynamic> json) {
  List<Ingredient> ingredientList = [];
  json.forEach((n) {
    Ingredient ingredient = Ingredient(
        id: n["id"] as int,
        name: n["name"] as String,
        amount: n["amount"] is int ? 0.0 : n["amount"] as double,
        unit: n["unit"] as String,
        nutrients: nutrientsListFromJson(n["nutrients"]));
    ingredientList.add(ingredient);
  });

  return ingredientList;
}

//Converts API list of Nutrition equipments to Equipment List
List<Equipment> equipmentListFromJson(List<dynamic> json) {
  List<Equipment> equipmentList = [];
  json.forEach((e) {
    Equipment equipment = Equipment(
        id: e["id"] as int,
        name: e["name"] as String,
        localizedName: e["name"] as String,
        image: e["name"] as String);
    equipmentList.add(equipment);
  });

  return equipmentList;
}

//Converts API list of analyzed instruction steps to Step List
List<Step> stepsListFromJson(List<dynamic> json) {
  List<Step> stepsList = [];
  json.forEach((s) {
    List<Equipment> ingredientsList = equipmentListFromJson(s["ingredients"]);
    List<Equipment> equipmentList = equipmentListFromJson(s["equipment"]);

    Step step = Step(
        number: s["number"] as int,
        step: s["step"] as String,
        ingredients: ingredientsList as List<Equipment>,
        equipment: equipmentList as List<Equipment>);
    stepsList.add(step);
  });

  return stepsList;
}

//Converts API list of analyzed instructions to AnalyzedInstruction List
List<AnalyzedInstruction> analyzedInstructionListFromJson(List<dynamic> json) {
  List<AnalyzedInstruction> analyzedInstructionList = [];
  json.forEach((n) {
    AnalyzedInstruction analyzedInstruction = AnalyzedInstruction(
      name: n["name"] as String,
      steps: stepsListFromJson(n["steps"]),
    );
    analyzedInstructionList.add(analyzedInstruction);
  });

  return analyzedInstructionList;
}