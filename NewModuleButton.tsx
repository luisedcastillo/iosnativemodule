import React from 'react';
import {NativeModules, Button} from 'react-native';

const {RNCalendarModule} = NativeModules;

console.log('NativeModuleCalendarModule');
console.log(NativeModules);

const NewModuleButton = () => {
  const onPress = async () => {
    console.log('We will invoke the native module here!');
    //RNCalendarModule.createCalendarEvent('testName', 'testLocation');
    const response = await NativeModules.HelloWorld.ShowMessage(
      '4841050100007D004f4e5f496e7465726e65745f322e34475f313831347C41636365737351335f3234373032357C3432317C353638327C32382e373230303831337C2d3130362e303132383633337C65794a68624763694f694a49557a49314e694973496e523563434936496b705856434a392e65794a31626d6c7864575666626d46745a534936496a51794d534973496d35695a6949364d54597a4e544d324f54517a4d4377695a586877496a6f784e6a4d314d7a63774d7a4d774c434a70595851694f6a45324d7a557a4e6a6b304d7a42392e4c304c492d587073505730674c70484c50745473442d5537773149396c6f53696463484b785164553877517C05010D0A',
      2.5,
    );
    console.log('Device Added:', response);
  };

  const onPressSync = () => {
    console.log('We will invoke the native module here!');
    NativeModules.HelloWorld.ShowMessageSync('Awesome!its working!', 2.5);
    console.log('It worked');
  };

  return (
    <>
      <Button
        title="Click to invoke your native module async!"
        color="#841584"
        onPress={onPress}
      />
      <Button
        title="Click to invoke your native module sync!"
        color="#841584"
        onPress={onPressSync}
      />
    </>
  );
};

export default NewModuleButton;
