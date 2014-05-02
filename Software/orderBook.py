#probably only need one definition of Ask/Bid Book since it seems they are doing the exact same thing

def shift(l, n, rl):
    if rl=="r":
        return l[n:] + l[:n]
    return l[:n] + l[n:]

class Order():
    def __init__(self, price, quantity):
        self.price = price
        self.quantity = quantity

    def __str__(self):
        return `self.quantity` + ": $" + `self.price`

class FullOrderBook:
    def __init__(self):
        self.askBook = Book()
        self.bidBook = Book()

    def __str__(self):
        askString = 'ASK\n---------\n'
        bidString = 'BID\n---------\n'

        for bookOrder in reversed(self.askBook.book):
             askString += `bookOrder.quantity` + ": $"+`bookOrder.price` + '\n'
            
        for bookOrder in reversed(self.bidBook.book):
             bidString  += `bookOrder.quantity` + ": $"+`bookOrder.price` + '\n'

        return askString + '\n\n' + bidString

    #checks inside of book to see if any orders can be executed
    def execute(self):
        askBk = self.askBook.book
        bidBk = self.bidBook.book
        if len(askBk)==0:
            print("No ask orders")
            return
        if len(bidBk)==0:
            print("No bid orders")
            return
        
        #while bid orders are higher than ask orders
        while bidBk[len(bidBk)-1].price > askBk[0].price:
            topBid = bidBk[len(bidBk)-1]
            bottomAsk = askBk[0]

            if topBid.quantity > bottomAsk.quantity:
                bidBk[0].quantity -= askBk[0].quantity
                askBk = askBk[1:]
            elif topBid.quantity <= bottomAsk.quantity:
                askBk[0].quantity -= bidBk[0].quantity
                bidBk = bidBk[:len(bidBk)-2]
            else:
                bidBk = bidBk[:len(bidBk)-2]
                askBk = askBk[1:]

                
               
                


#lowest priced order at index 0
class Book():
    
    def __init__(self):
        self.book = []

    def addToBook(self, order):
        print "HALLO ADD TO BOOK CALLED"
    
        if len(self.book) == 0:
            print "ABOUT TO APPEND First order"
            self.book.append(order)
        
        #check top and bottom of order book
        elif order.price < self.book[0].price:
            self.book.insert(0, order)

        elif order.price > self.book[len(self.book)-1].price:
            self.book.append(order)

        else: 
            for i in range(0, len(self.book)):
                if order.price == self.book[i].price:
                    self.book[i].quantity += order.quantity
                    break
    
                if order.price > self.book[i] and order.price < self.book[i+1].price:
                    temp = self.book[i+1:]
                    self.book = self.book[:i+1]
                    self.book.append(order)
                    self.book += temp
                    break 

        return

    def __str__(self):
        result = ''
        for bookOrder in self.book:
             result += `bookOrder.quantity` + ": $"+`bookOrder.price` + '\n'
        return result        
  
    def delete(self, index):
       temp = self.book[index+1:]
       self.book = self.book[:index]
       self.book += temp
       return

   

#removes the specified amount from an order book
def deleteOrder (myOrder, myBook):
    for i in range(0, len(myBook.book)):
        order = myBook.book[i]
        if myOrder.price == order.price:
            order.quantity -= myOrder.quantity
            if order.quantity == 0:
                myBook.delete(i)
                break
            break






#test our orderbook functions
#order1 = Order(3, 3)
#order2 = Order (2, 5)
#order3 = Order(3,5)
#order4 = Order(5, 3)
#order5 = Order(1, 4)
#order6 = Order(2, 1)
#orderDelete = Order(3,3)
#
#myOrders = [order1, order2, order3, order4, order5, order6] 
#fullBook = FullOrderBook()
#for o in myOrders:
#    fullBook.askBook.addToBook(o)
#
#print fullBook
#
#for o in myOrders:
#    fullBook.bidBook.addToBook(o)
#    fullBook.execute()
#
#print fullBook




