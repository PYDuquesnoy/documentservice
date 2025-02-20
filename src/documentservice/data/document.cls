/// This Data Class extends the JSON Adaptor.
/// It provides the ability to produce JSON data with a large property that is of type Stream.
/// it solves the issue that there is no way to set a property in %DynamicObject ({}) to be of type %Stream
Class documentservice.data.document Extends (%RegisteredObject, %JSON.Adaptor)
{

Property content As %Stream.TmpBinary;

}
