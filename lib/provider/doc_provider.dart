import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:heathfirst_mobile/provider/app_provider.dart';
import 'package:heathfirst_mobile/service/data.dart';

final docAsyncProvider = FutureProvider(
  (ref) async {
    final token = ref.read(accessTokenProvider);
    final base_url = ref.read(baseUrl);
    print('-----=[Doc async]=------');
    
    return await fetchDataDoc(token: token, urlBase: base_url);
  }
);

final searchProvider = StateProvider<String>((ref) => '');

final filteredDoctorsProvider = Provider((ref){
   final doctors = ref.watch(docAsyncProvider).value ?? [];
   final query = ref.watch(searchProvider).toLowerCase();

   return doctors.where((doc){

      return doc['last_name']
          .toString()
          .toLowerCase()
          .contains(query)

      || doc['first_name']
          .toString()
          .toLowerCase()
          .contains(query)

      || doc['speciality']
          .toString()
          .toLowerCase()
          .contains(query)

      || doc['addressCabinet']
          .toString()
          .toLowerCase()
          .contains(query);

  }).toList();

});