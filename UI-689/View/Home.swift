//
//  Home.swift
//  UI-689
//
//  Created by nyannyan0328 on 2022/10/04.
//

import SwiftUI

struct Home: View {
    @State var messages : [Meesage] = []
    var body: some View {
        
        VStack{
            
            
            
            SwipCrouselView(items: messages, id: \.id) { msg, size in
                
                Image(msg.imageFiles)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width,height: size.width)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
             .frame(width: 200,height: 300)
            
            
        }
        .onAppear{
            
            for index in 1...5{
                
                messages.append(Meesage(imageFiles: "p\(index)"))
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
      ContentView()
    }
}

struct SwipCrouselView<Content : View,ID,Item> : View where Item:RandomAccessCollection,Item.Element:Equatable,Item.Element:Identifiable,ID:Hashable{
    
   
    var id : KeyPath<Item.Element,ID>
    
    var items : Item
    
    var content : (Item.Element,CGSize) -> Content
    
    var traiglingCards : Int = 0
    
    
    init(items : Item, id: KeyPath<Item.Element,ID>,traiglingCards: Int = 3,@ViewBuilder content : @escaping(Item.Element,CGSize) -> Content) {
        self.id = id
        self.items = items
        self.content = content
        self.traiglingCards = traiglingCards
    }
    @State var offset : CGFloat = 0
    
    @State var showRight : Bool = false
    @State var currentindex : Int = 0
    
    var body: some View{
        
        GeometryReader{
            
            let size = $0.size
            
            ZStack{
                
                ForEach(items){item in
                    CardView(item: item, size: size)
                       .overlay(content: {
                            
                            let index = indexOf(item: item)
                            
                            if (currentindex + 1) == index && Array(items).indices.contains(currentindex - 1) && showRight{
                                
                                CardView(item: item, size: size)
                                    .transition(.identity)
                                
                            }
                             
                            
                                
                                
                        })
                        .zIndex(zIndexOf(item: item))
                    
                    
                }
            }
         
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(
            
            DragGesture()
                .onChanged({ value in
                    
                    showRight = (value.translation.width > 0)
                    
                    offset = (value.translation.width / (size.width + 30)) * size.width
                    
                })
                .onEnded({ value in
                    
                    let translation = value.translation.width
                    
                    if translation > 0{
                        
                        deCrease(translation: translation)
                        
                        
                    }
                    else{
                        
                        inCrease(translation: translation)
                        
                    }
                    
                    withAnimation(.easeInOut(duration: 0.3)){
                        
                        offset = .zero
                    }
                    
                })
            
            )
        }
    }
    
    func rotationFor(item : Item.Element)->CGFloat{
        
        let index = indexOf(item: item) - currentindex
        
        if index > 0{
            if index > traiglingCards{
                
                return CGFloat(traiglingCards) * 3
                
            }
            
            return CGFloat(index) * 3
            
        }
        
        if -index > traiglingCards{
            
            return CGFloat(traiglingCards) * 3
            
            
        }
        
        return CGFloat(index) * 3
        
       
    }
    
    func inCrease(translation : CGFloat){
        
        if translation < 0 && -translation > 110 && currentindex < (items.count - 1){
            
            withAnimation(.easeInOut(duration: 0.5)){
                
                currentindex += 1
            }
        }
        
        
    }
    
    func deCrease(translation : CGFloat){
        
        
        if translation > 0 && translation > 110 && currentindex > 0{
            
            withAnimation(.easeInOut(duration: 0.5)){
                
                currentindex -= 1
            }
        }
        else{
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                
             showRight = false
            }
        }
        
        
    }
    @ViewBuilder
    func CardView(item : Item.Element,size : CGSize) -> some View{
        
        let index = indexOf(item: item)
        content(item,size)
            .scaleEffect(scaleFor(item: item))
            
            .offset(x:currentindex == index ? offset : 0)
            .offset(x:offsetFor(item: item))
            .rotationEffect(.init(degrees: rotationFor(item:item)),anchor:currentindex > index ? .topLeading : .topTrailing)
            .rotationEffect(.init(degrees: rotationForGesture(index: index)),anchor: .top)
            .scaleEffect(scaleForGesture(index: index))
    }
    
    func scaleForGesture(index : Int) ->CGFloat{
        
        
        let progress = 1 - ((offset > 0 ? offset : -offset) / screenSize.width)
        
        return (currentindex == index ? (progress > 0.76 ? progress : 0.75) : 1)
        
    }
    
    func rotationForGesture(index : Int) -> CGFloat{
        
        let progress = (offset / screenSize.width) * 30
        
        return (currentindex == index ? progress : 0)
    }
    
    func scaleFor(item : Item.Element)->CGFloat{
        
        let index = indexOf(item: item) - currentindex
        
        if index > 0{
            
            if index > traiglingCards{
                
                return 1 - (CGFloat(traiglingCards) / 20)
                
            }
            
            return 1 - (CGFloat(index) / 20)
        }
        
        
        if -index > traiglingCards{
            
            return 1 - (CGFloat(traiglingCards) / 20)
        }
        
        return 1 + (CGFloat(index) / 20)
        
        
    }
    
    func offsetFor(item : Item.Element)->CGFloat{
        
        let index = indexOf(item: item) - currentindex
        
        if index > 0{
            
            if index > traiglingCards{
                
                return 20 * CGFloat(traiglingCards)
                
            }
            
            return CGFloat(index) * 20
            
            
        }
        
        
        if -index > traiglingCards{
            
            return -20 * CGFloat(traiglingCards)
            
        }
        
        return CGFloat(index) * 20
        
    }
    
    func zIndexOf(item : Item.Element)->Double{
        
        let index = indexOf(item: item)
        
        let totalCount = items.count
        
        
        return currentindex == index ? 10 : (currentindex < index ? Double(totalCount - index) : Double(index - totalCount))
        
        
        
        
    }
    
    func indexOf(item : Item.Element)->Int{
        
       let arrayItems = Array(items)
        
        if let index = arrayItems.firstIndex(of: item){
            
            return index
        }
        return 0
        
    }
  
}

var screenSize : CGSize = {
   
    guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return .zero}
    
    return window.screen.bounds.size
    
    
}()
