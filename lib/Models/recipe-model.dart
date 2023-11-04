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
      resultsList.add(Result.fromJson(r));
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
  String firebaseID;

  Result(
      {
      required this.vegetarian,
      required this.vegan,
      this.glutenFree = false,
      this.dairyFree = false,
      this.veryHealthy = false,
      this.cheap = false,
      this.veryPopular = false,
      this.sustainable = false,
      this.lowFodmap = false,
      this.weightWatcherSmartPoints = 0,
      this.gaps = "",
      this.preparationMinutes = 0,
      this.cookingMinutes = 0,
      this.aggregateLikes = 0,
      this.healthScore = 0,
      this.creditsText = "",
      this.sourceName = "",
      this.pricePerServing = 0,
      this.id = 0,
      required this.title,
      required this.readyInMinutes,
      required this.servings,
      this.sourceUrl = "",
      required this.image,
      this.imageType = "jpg",
      required this.nutrition,
      this.summary = "",
      this.cuisines = const [],
      this.dishTypes = const [],
      this.diets = const [],
      this.occasions = const [],
      required this.analyzedInstructions,
      this.spoonacularSourceUrl = "",
      this.firebaseID = ""});

  factory Result.fromJson(Map<String, dynamic> json, {String id = ""}) {
    //List of Nutrients mapped from API nutrients list
    List<Nutrient> nutrientsList =
        nutrientsListFromJson(json["nutrition"]["nutrients"]);

    //List of properties mapped from API nutrients list
    List<Property> propertiesList =
        propertiesListFromJson(json["nutrition"]["properties"]);

    //List of flavanoids mapped from API nutrients list
    List<Flavanoid> flavanoidsList =
        flavanoidsListFromJson(json["nutrition"]["flavonoids"]);

    //List of flavanoids mapped from API nutrients list
    List<Ingredient> ingredientsList =
        ingredientListFromJson(json["nutrition"]["ingredients"]);

    //Caloric Breakdown mapped from API
    CaloricBreakdown caloricBreakdownObj = CaloricBreakdown(
      percentProtein:
          json["nutrition"]["caloricBreakdown"]["percentProtein"] as double,
      percentFat: json["nutrition"]["caloricBreakdown"]["percentFat"] as double,
      percentCarbs:
          json["nutrition"]["caloricBreakdown"]["percentCarbs"] as double,
    );

    //Weight Per Serving data mapped from API
    WeightPerServing weightPerServingObj = WeightPerServing(
        amount: json["nutrition"]["weightPerServing"]["amount"] as int,
        unit: json["nutrition"]["weightPerServing"]["unit"] as String);

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
        analyzedInstructionListFromJson(json["analyzedInstructions"]);

    return Result(
        vegetarian: json["vegetarian"] as bool,
        vegan: json["vegan"] as bool,
        glutenFree: json["glutenFree"] as bool,
        dairyFree: json["dairyFree"] as bool,
        veryHealthy: json["veryHealthy"] as bool,
        cheap: json["cheap"] as bool,
        veryPopular: json["veryPopular"] as bool,
        sustainable: json["sustainable"] as bool,
        lowFodmap: json["lowFodmap"] as bool,
        weightWatcherSmartPoints: json["weightWatcherSmartPoints"] as int,
        gaps: json["gaps"] as String,
        preparationMinutes: json["preparationMinutes"] as int,
        cookingMinutes: json["cookingMinutes"] as int,
        aggregateLikes: json["aggregateLikes"] as int,
        healthScore: json["healthScore"] as int,
        creditsText: json["creditsText"] as String,
        sourceName: json["sourceName"] as String,
        pricePerServing: json["pricePerServing"] as double,
        id: json["id"] as int,
        title: json["title"] as String,
        readyInMinutes: json["readyInMinutes"] as int,
        servings: json["servings"] as int,
        sourceUrl: json["sourceUrl"] as String,
        image: json["image"] as String,
        imageType: json["imageType"] as String,
        nutrition: nutritionObj,
        summary: json["summary"] as String,
        cuisines: json["cuisines"] as List<dynamic>,
        dishTypes: json["dishTypes"] as List<dynamic>,
        diets: json["diets"] as List<dynamic>,
        occasions: json["occasions"] as List<dynamic>,
        analyzedInstructions: analyzedInstructionList,
        spoonacularSourceUrl: json["spoonacularSourceUrl"] as String,
        firebaseID: id);
  }

  Map<String, dynamic> toMap() {
    return {
      'vegetarian': vegetarian,
      'vegan': vegan,
      'glutenFree': glutenFree,
      'dairyFree': dairyFree,
      'veryHealthy': veryHealthy,
      'cheap': cheap,
      'veryPopular': veryPopular,
      'sustainable': sustainable,
      'lowFodmap': lowFodmap,
      'weightWatcherSmartPoints': weightWatcherSmartPoints,
      'gaps': gaps,
      'preparationMinutes': preparationMinutes,
      'cookingMinutes': cookingMinutes,
      'aggregateLikes': aggregateLikes,
      'healthScore': healthScore,
      'creditsText': creditsText,
      'sourceName': sourceName,
      'pricePerServing': pricePerServing,
      'id': id,
      'title': title,
      'readyInMinutes': readyInMinutes,
      'servings': servings,
      'sourceUrl': sourceUrl,
      'image': image,
      'imageType': imageType,
      'nutrition': nutrition.toMap(),
      'summary': summary,
      'cuisines': cuisines,
      'dishTypes': dishTypes,
      'diets': diets,
      'occasions': occasions,
      'analyzedInstructions': analyzedInstructions
          .map((instruction) => instruction.toMap())
          .toList(),
      'spoonacularSourceUrl': spoonacularSourceUrl,
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'localizedName': localizedName,
      'image': image,
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'nutrients': nutrients.map((nutrient) => nutrient.toMap()).toList(),
      'properties': properties.map((property) => property.toMap()).toList(),
      'flavonoids': flavonoids.map((flavanoid) => flavanoid.toMap()).toList(),
      'ingredients':
          ingredients.map((ingredient) => ingredient.toMap()).toList(),
      'caloricBreakdown': caloricBreakdown.toMap(),
      'weightPerServing': weightPerServing.toMap(),
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'percentOfDailyNeeds': percentOfDailyNeeds,
    };
  }
}

//Nutrition properties data
class Property {
  String name;
  double amount;
  String unit;

  Property({required this.name, required this.amount, required this.unit});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }
}

//Nutrition flavanoid data
class Flavanoid {
  String name;
  double amount;
  String unit;

  Flavanoid({required this.name, required this.amount, required this.unit});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'nutrients': nutrients.map((nutrient) => nutrient.toMap()).toList(),
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'percentProtein': percentProtein,
      'percentFat': percentFat,
      'percentCarbs': percentCarbs,
    };
  }
}

//Recipe Weight per Serving
class WeightPerServing {
  int amount;
  String unit;

  WeightPerServing({
    required this.amount,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'unit': unit,
    };
  }
}

//Instructions for cooking a recipe
class AnalyzedInstruction {
  String name;
  List<Step> steps;

  AnalyzedInstruction({
    required this.name,
    required this.steps,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'steps': steps.map((step) => step.toMap()).toList(),
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'step': step,
      'ingredients': ingredients.map((equipment) => equipment.toMap()).toList(),
      'equipment': equipment.map((equipment) => equipment.toMap()).toList(),
    };
  }
}

//Converts API list of Nutrition nutrients to Nutrient List
List<Nutrient> nutrientsListFromJson(List<dynamic> apiNutrientList) {
  List<Nutrient> nutrientsList = []; //List of Nutrients to be returned
  //Loops through "nutrient" list from API and maps
  //each nutrient to a Nutrient object, then adds that to the nutrients List
  apiNutrientList.forEach((n) {
    Nutrient nutrient = Nutrient(
        name: n["name"] as String,
        //checks if this value is int, if it is, convert it to a double else return
        //the value bc it is correct type (double)
        amount: n["amount"] is int ? 0.0 + n["amount"] : n["amount"] as double,
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
        //checks if this value is int, if it is, convert it to a double else return
        //the value bc it is correct type (double)
        amount: n["amount"] is int ? 0.0 + n["amount"] : n["amount"] as double,
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
        //checks if this value is int, if it is, convert it to a double else return
        //the value bc it is correct type (double)
        amount: n["amount"] is int ? 0.0 + n["amount"] : n["amount"] as double,
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
        //checks if this value is int, if it is, convert it to a double else return
        //the value bc it is correct type (double)
        amount: n["amount"] is int ? 0.0 + n["amount"] : n["amount"] as double,
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
