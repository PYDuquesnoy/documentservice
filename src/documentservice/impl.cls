/// Upload and Download Documents via REST/JSON<br/>
/// Business logic class defined by OpenAPI in documentservice.spec<br/>
/// Created Feb 19, 2025 12:55:48
Class documentservice.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// Directory where to Store the Files Received by the Server
Parameter DIRECTORY = "/home/irisowner/dev/serverdata/";

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 1;

/// Adds a new Document in the FileSystem and returns a DocumentID Reference to download<br/>
/// The method arguments hold values for:<br/>
///     body, Document information<br/>
ClassMethod PostDocument(body As %DynamicObject) As %DynamicObject
{
    Do ..%SetStatusCode(200)
	//We can access the fileName Property this way. But we don't really use it in this example
    //to avoid colliding filenames loaded by the client. So we alway create new Files with PostDocument
	set tfileName=body.fileName
	
	//Extacts the property called "content" as a 
    //%Stream.DynamicBinary (this is required for base64 content larger than 3.6MB)
	set tBase64=body.%Get("content","","stream")
	if tBase64.Size="" {
		do ..%SetStatusCode(204)  //No Content
	}
	//Output File to Store the Binary Content ( a PDF file would be binary)
    //The Server Filename is made up from a counter
	Set tOutputFile=##class(%Stream.FileBinary).%New()
	Set tOutputFile.Filename=..#DIRECTORY_##class(%File).GetFilename("File_"_$increment(^FileCounter)_".bin")
	
	set tSC=..Base64Decode(tBase64,tOutputFile)
	if ($SYSTEM.Status.IsError(tSC)) {
		do ..%SetStatusCode(422)  //UnProcessable content
		return ""
	}
	d tOutputFile.%Save()
	
	//---- OK
	set tRsp={}
	set tRsp.reference=##class(%File).GetFilename(tOutputFile.Filename)
	return tRsp
}

/// returns the content of 1 Document<br/>
/// The method arguments hold values for:<br/>
///     reference, A Reference to the Document<br/>
ClassMethod GetDocument(reference As %String) As %DynamicObject
{
    do ..%SetStatusCode(200)
	
	If '##class(%File).Exists(..#DIRECTORY_##class(%File).GetFilename(reference)) {
		do ..%SetStatusCode(404)
		return ""
	}

	set tInFile=##class(%Stream.FileBinary).%New()
	set tSC=tInFile.LinkToFile(..#DIRECTORY_##class(%File).GetFilename(reference))
	
	set tOut=##class(documentservice.data.document).%New()
	set tOut.content=##class(%Stream.TmpBinary).%New()
	do tOut.content.CopyFrom(tInFile)
	//set tSC=..Base64Encode(tInFile,tOut.content)
	do tOut.%JSONExportToStream(.binStream)
	return binStream
}

/// ------------------------------------------------------------------------------
/// Utility Functions Copied from HS.Util.StreamUtils
/// 
/// Base64 decode a string or a stream into a stream
/// 
/// <example>
/// Do ..Base64Decode("SGVsbG8=",.tDecodedStream)
/// </example>
/// 
/// By default a %Stream.GlobalBinary is returned. Caller may override by
/// sending in a different stream. For example:
/// <example>
/// Set tInputFile=##class(%Stream.FileBinary).%New()
/// Set tInputFile.Filename="c:\data.b64"
/// Set tOutputFile=##class(%Stream.FileBinary).%New()
/// Set tOutputFile.Filename="c:\data.dat"
/// Do ##class(HS.Util.StreamUtils).Base64Decode(tInputFile,tOutputFile)
/// 
/// </example>
ClassMethod Base64Decode(pInput = "", ByRef pOutput As %Stream.GlobalBinary = "") As %Status
{
	Set tSC=$$$OK
	Try {
		If '$IsObject(pOutput) Set pOutput=##class(%Stream.GlobalBinary).%New()
		
		#; Remove newlines from input then decode the largest value
		#; possible that has a length which is a factor of 4
		If $IsObject(pInput) {
			Set tLeftOver=""
			While 'pInput.AtEnd { 
				Set tValue=pInput.Read($$$MaxLocalLength-4)  
				Set tValue=tLeftOver_$TR(tValue,$C(13,10))
				Set tPos=$L(tValue)-($L(tValue)#4)
				Set tLeftOver=$e(tValue,tPos+1,*)
				Set tValue=$e(tValue,1,tPos)
				Do pOutput.Write($SYSTEM.Encryption.Base64Decode(tValue))
			}
		} Else {
			Do pOutput.Write($SYSTEM.Encryption.Base64Decode(pInput))
		}	
		Do pOutput.Rewind()
	} Catch ex { Set tSC=ex.AsStatus() }
	Quit tSC
}

/// Base64 encode a string or a stream into a stream
/// 
/// <example>
/// Do ..Base64Encode("Hello",.tEncodedStream)
/// </example>
/// 
/// By default a %Stream.GlobalCharacter is returned. Caller may override by
/// sending in any stream type that has a LineTerminator property. For example:
/// <example>
/// Set tInputFile=##class(%Stream.FileBinary).%New()
/// Set tInputFile.Filename="c:\data.dat"
/// Set tOutputFile=##class(%Stream.FileBinary).%New()
/// Set tOutputFile.Filename="c:\data.b64"
/// Do ##class(HS.Util.StreamUtils).Base64Encode(tInputFile,tOutputFile)
/// </example>
ClassMethod Base64Encode(pInput = "", ByRef pOutput As %Stream.GlobalCharacter = "") As %Status
{
	Set tSC=$$$OK
	Try {
		If '$IsObject(pOutput) Set pOutput=##class(%Stream.GlobalCharacter).%New()
		
		#; Get the biggest buffer possible
		#; Assumes output is 78 characters (76 + 2 newlines) per base-64 line
		#; ($$$MaxLocalLength\78*57) should work, but it doesn't so just use 50% floored to nearst power of 57
		Set tMax=$$$MaxLocalLength*.5\1
		Set tMax=tMax-(tMax#57)
		
		If $IsObject(pInput) {
			Set tCurrLineLen=0
			While 'pInput.AtEnd { 
				Set tData=pInput.Read(tMax)
				Set tValue=$SYSTEM.Encryption.Base64Encode(tData)
				Do pOutput.Write(tValue) 
				If 'pInput.AtEnd Do pOutput.Write(pOutput.LineTerminator)
			}
		} Else {
			Set tPos=1
			While tPos<$l(pInput) {
				Set tEnd=tPos+tMax-1
				Set tValue=$e(pInput,tPos,tEnd)
				Set tValue=$SYSTEM.Encryption.Base64Encode(pInput)
				Do pOutput.Write(tValue)
				Set tPos=tEnd+1
				If tPos<$l(pInput) Do pOutput.Write(pOutput.LineTerminator)
			}
		}	
			Do pOutput.Rewind()
	} Catch ex { Set tSC=ex.AsStatus() }
	Quit tSC
}

}
