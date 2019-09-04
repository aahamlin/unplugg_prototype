abstract class BlocBase<T> {

  Stream<T> get stream;

  void dispose();

}